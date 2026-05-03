import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum PinCategory { food, cafe, travel, shop, other }

class Pin {
  const Pin({
    required this.id,
    required this.groupId,
    required this.title,
    required this.lat,
    required this.lng,
    required this.createdBy,
    this.description,
    this.category = PinCategory.other,
    this.createdAt,
  });

  final String id;
  final String groupId;
  final String title;
  final String? description;
  final double lat;
  final double lng;
  final PinCategory category;
  final String createdBy;
  final DateTime? createdAt;

  LatLng get latLng => LatLng(lat, lng);

  factory Pin.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String groupId,
  ) {
    final d = doc.data() ?? {};
    return Pin(
      id: doc.id,
      groupId: groupId,
      title: d['title'] as String? ?? '',
      description: d['description'] as String?,
      lat: (d['lat'] as num).toDouble(),
      lng: (d['lng'] as num).toDouble(),
      category: PinCategory.values.firstWhere(
        (c) => c.name == (d['category'] as String? ?? 'other'),
        orElse: () => PinCategory.other,
      ),
      createdBy: d['createdBy'] as String? ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'description': description,
        'lat': lat,
        'lng': lng,
        'category': category.name,
        'createdBy': createdBy,
        'createdAt': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
      };
}
