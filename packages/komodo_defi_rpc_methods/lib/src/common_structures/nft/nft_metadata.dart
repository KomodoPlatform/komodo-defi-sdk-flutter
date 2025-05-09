// class NftMetadata {
//   NftMetadata({
//     this.image,
//     this.imageUrl,
//     this.imageDomain,
//     this.name,
//     this.description,
//     this.attributes,
//     this.animationUrl,
//     this.animationDomain,
//     this.externalUrl,
//     this.externalDomain,
//     this.imageDetails,
//   });

//   factory NftMetadata.fromJson(Map<String, dynamic> json) => NftMetadata(
//         image: json['image'],
//         imageUrl: json['image_url'],
//         imageDomain: json['image_domain'],
//         name: json['name'],
//         description: json['description'],
//         attributes: json['attributes'] != null
//             ? List<Map<String, dynamic>>.from(json['attributes'])
//             : null,
//         animationUrl: json['animation_url'],
//         animationDomain: json['animation_domain'],
//         externalUrl: json['external_url'],
//         externalDomain: json['external_domain'],
//         imageDetails: json['image_details'],
//       );
//   final String? image;
//   final String? imageUrl;
//   final String? imageDomain;
//   final String? name;
//   final String? description;
//   final List<Map<String, dynamic>>? attributes;
//   final String? animationUrl;
//   final String? animationDomain;
//   final String? externalUrl;
//   final String? externalDomain;
//   final Map<String, dynamic>? imageDetails;

//   Map<String, dynamic> toJson() => {
//         if (image != null) 'image': image,
//         if (imageUrl != null) 'image_url': imageUrl,
//         if (imageDomain != null) 'image_domain': imageDomain,
//         if (name != null) 'name': name,
//         if (description != null) 'description': description,
//         if (attributes != null) 'attributes': attributes,
//         if (animationUrl != null) 'animation_url': animationUrl,
//         if (animationDomain != null) 'animation_domain': animationDomain,
//         if (externalUrl != null) 'external_url': externalUrl,
//         if (externalDomain != null) 'external_domain': externalDomain,
//         if (imageDetails != null) 'image_details': imageDetails,
//       };
// }
