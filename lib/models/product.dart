class Product {
  const Product({
    required this.id,
    required this.serverId,
    required this.name,
    required this.price,
    required this.category,
    this.sku,
    this.barcode,
    this.stock = 0,
    this.costPrice = 0,
    this.categoryId,
    this.imageUrl,
    this.allowSaleOutOfStock = false,
  });

  final String id;
  final int? serverId;
  final String name;
  final double price;
  final String category;
  final String? sku;
  final String? barcode;
  final int stock;
  final double costPrice;
  final int? categoryId;
  final String? imageUrl;
  final bool allowSaleOutOfStock;

  bool get canSell => allowSaleOutOfStock || stock > 0;

  factory Product.fromServerJson(
    Map<String, dynamic> json, {
    Map<int, String> categoryNames = const {},
  }) {
    final serverId = _int(json['id'] ?? json['server_id']);
    var price = _num(json['selling_price']);
    if (price == 0) price = _num(json['display_price']);
    if (price == 0) price = _num(json['price']);

    var stock = _num(json['stock']);
    if (stock == 0) stock = _num(json['stock_quantity']);
    if (stock == 0) stock = _num(json['current_stock']);

    var cost = _num(json['average_cost']);
    if (cost == 0) cost = _num(json['cost_price']);

    final categoryId = _int(json['category_id']);
    var category = json['category_name']?.toString() ??
        json['category']?.toString() ??
        '';
    if (category.isEmpty && categoryId != null) {
      category = categoryNames[categoryId] ?? 'Other';
    }
    if (category.isEmpty) category = 'Other';

    String? imageUrl = json['image_url']?.toString();
    final images = json['product_images'];
    if ((imageUrl == null || imageUrl.isEmpty) && images is List && images.isNotEmpty) {
      imageUrl = images.first?.toString();
    }

    return Product(
      id: serverId?.toString() ?? json['local_id']?.toString() ?? '',
      serverId: serverId,
      name: (json['product_name'] ?? json['name'] ?? 'Product').toString(),
      price: price,
      category: category,
      sku: json['item_code']?.toString(),
      barcode: json['barcode']?.toString(),
      stock: stock.round(),
      costPrice: cost,
      categoryId: categoryId,
      imageUrl: imageUrl,
      allowSaleOutOfStock: json['allow_sale_out_of_stock'] == true,
    );
  }

  static double _num(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  static int? _int(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }
}
