// ═══════════════════════════════════════════════════════════════════
// mua_model.dart
// Field mengikuti PERSIS response GET /api/muas dan GET /api/muas/{id}
// ═══════════════════════════════════════════════════════════════════

class ServiceModel {
  final int     id;
  final String  name;
  final String? description;
  final double  price;
  final String? category;

  ServiceModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.category,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id         : json['id'],
      name       : json['name'],
      description: json['description'],
      price      : (json['price'] as num).toDouble(),
      category   : json['category'],
    );
  }
}

class PortfolioModel {
  final int     id;
  final String? title;
  final String? caption;
  final String  imageUrl;
  final String? styleCategory;
  final String? createdAt;

  PortfolioModel({
    required this.id,
    this.title,
    this.caption,
    required this.imageUrl,
    this.styleCategory,
    this.createdAt,
  });

  factory PortfolioModel.fromJson(Map<String, dynamic> json) {
    return PortfolioModel(
      id            : json['id'],
      title         : json['title'],
      caption       : json['caption'],
      imageUrl      : json['image_url'],
      styleCategory : json['style_category'],
      createdAt     : json['created_at'],
    );
  }
}

class MuaModel {
  final int             id;
  final String          name;        // dari user.name
  final String?         avatar;      // dari user.avatar
  final String?         location;
  final String?         bio;
  final int?            experienceYears;
  final double          rating;
  final int             totalReviews;
  final List<String>    styleTags;
  final String?         certificate;
  final bool            isVerified;
  final List<ServiceModel>   services;
  // Hanya ada di detail (GET /api/muas/{id})
  final List<PortfolioModel> portfolios;
  final String?         phone;

  MuaModel({
    required this.id,
    required this.name,
    this.avatar,
    this.location,
    this.bio,
    this.experienceYears,
    required this.rating,
    required this.totalReviews,
    required this.styleTags,
    this.certificate,
    required this.isVerified,
    required this.services,
    this.portfolios = const [],
    this.phone,
  });

  factory MuaModel.fromJson(Map<String, dynamic> json) {
    return MuaModel(
      id             : json['id'],
      name           : json['name'],
      avatar         : json['avatar'],
      location       : json['location'],
      bio            : json['bio'],
      experienceYears: json['experience_years'],
      rating         : (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews   : json['total_reviews'] ?? 0,
      styleTags      : json['style_tags'] != null
                         ? List<String>.from(json['style_tags'])
                         : [],
      certificate    : json['certificate'],
      isVerified     : json['is_verified'] ?? false,
      services       : json['services'] != null
                         ? (json['services'] as List)
                             .map((s) => ServiceModel.fromJson(s))
                             .toList()
                         : [],
      portfolios     : json['portfolios'] != null
                         ? (json['portfolios'] as List)
                             .map((p) => PortfolioModel.fromJson(p))
                             .toList()
                         : [],
      phone          : json['phone'],
    );
  }
}

class ReviewModel {
  final int    id;
  final double rating;
  final String? comment;
  final String  reviewerName;
  final String? reviewerAvatar;
  final String? createdAt;

  ReviewModel({
    required this.id,
    required this.rating,
    this.comment,
    required this.reviewerName,
    this.reviewerAvatar,
    this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id            : json['id'],
      rating        : (json['rating'] as num).toDouble(),
      comment       : json['comment'],
      reviewerName  : json['reviewer']?['name'] ?? 'Anonim',
      reviewerAvatar: json['reviewer']?['avatar'],
      createdAt     : json['created_at'],
    );
  }
}