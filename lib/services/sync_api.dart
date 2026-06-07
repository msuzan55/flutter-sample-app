import '../config/api_config.dart';
import '../models/product.dart';
import '../models/user.dart';
import 'api_client.dart';

class SyncApi {
  SyncApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> fetchInitialSync(PosUser user) async {
    final paths = ApiConfig.initialSyncPaths(
      hasBusinessId: user.businessId != null,
    );

    ApiException? lastError;
    for (final path in paths) {
      try {
        final response = await _client.get(
          path,
          timeout: ApiConfig.syncTimeout,
        );
        if (response.statusCode == 200) {
          return _client.decodeJsonMap(response);
        }
        lastError = ApiException(
          _client.errorMessage(response),
          statusCode: response.statusCode,
          path: path,
        );
      } on ApiException catch (e) {
        lastError = e;
      } catch (e) {
        lastError = ApiException(e.toString(), path: path);
      }
    }
    throw lastError ?? ApiException('Initial sync failed');
  }

  List<Product> parseProducts(Map<String, dynamic> data, PosUser user) {
    final categoryNames = _categoryNameMap(data);
    final raw = <dynamic>[];

    final tables = data['tables'];
    if (tables is Map) {
      raw.addAll(tables['products'] as List? ?? []);
      raw.addAll(tables['product'] as List? ?? []);
    }
    raw.addAll(data['products'] as List? ?? []);

    final seen = <String>{};
    final products = <Product>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      if (!_matchesScope(map, user)) continue;
      if (!_isActiveProduct(map)) continue;

      final product = Product.fromServerJson(
        map,
        categoryNames: categoryNames,
      );
      if (product.serverId == null) continue;
      final key = product.serverId.toString();
      if (seen.contains(key)) continue;
      seen.add(key);
      products.add(product);
    }
    return products;
  }

  List<String> parseCategories(List<Product> products) {
    final set = <String>{'All'};
    for (final p in products) {
      if (p.category.isNotEmpty) set.add(p.category);
    }
    return set.toList()
      ..sort((a, b) {
        if (a == 'All') return -1;
        if (b == 'All') return 1;
        return a.compareTo(b);
      });
  }

  Future<Map<String, dynamic>> pushChanges(
    List<Map<String, dynamic>> changes,
  ) async {
    final response = await _client.postJson(ApiConfig.syncPush, {
      'changes': changes,
    });
    if (response.statusCode != 200) {
      throw ApiException(
        _client.errorMessage(response),
        statusCode: response.statusCode,
        path: ApiConfig.syncPush,
      );
    }
    return _client.decodeJsonMap(response);
  }

  Map<int, String> _categoryNameMap(Map<String, dynamic> data) {
    final map = <int, String>{};
    final lists = <dynamic>[];

    final tables = data['tables'];
    if (tables is Map) {
      lists.addAll(tables['categories'] as List? ?? []);
      lists.addAll(tables['category'] as List? ?? []);
    }
    lists.addAll(data['categories'] as List? ?? []);

    for (final item in lists) {
      if (item is! Map) continue;
      final id = item['id'];
      final name = item['category_name'] ?? item['name'];
      if (id != null && name != null) {
        map[int.tryParse(id.toString()) ?? 0] = name.toString();
      }
    }
    return map;
  }

  bool _matchesScope(Map<String, dynamic> row, PosUser user) {
    if (user.branchId != null && row['branch_id'] != null) {
      if (row['branch_id'].toString() != user.branchId.toString()) return false;
    }
    if (user.businessId != null && row['business_id'] != null) {
      if (row['business_id'].toString() != user.businessId.toString()) {
        return false;
      }
    }
    return true;
  }

  bool _isActiveProduct(Map<String, dynamic> row) {
    if (row['deleted_at'] != null && row['deleted_at'].toString().isNotEmpty) {
      return false;
    }
    final active = row['is_active'];
    if (active == false || active == 0 || active == '0') return false;
    return true;
  }
}
