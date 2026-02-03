import 'package:lets_jam/models/post_model.dart';
import 'package:lets_jam/models/region_enum.dart';
import 'package:lets_jam/models/session_enum.dart';

/// MARK: FindBandModel을 따로 만들어야 할까?
class FindSessionUploadModel {
  String title;
  List<SessionEnum> sessions;
  List<District> regions;
  String contact;
  String description;
  List<String> tags;
  List<String> images;

  FindSessionUploadModel.init()
      : title = '',
        sessions = [],
        regions = [],
        contact = '',
        description = '',
        tags = [],
        images = [];

  FindSessionUploadModel.fromPost(PostModel post)
      : title = post.title,
        sessions = post.sessions,
        regions = post.regions ?? [],
        contact = post.contact,
        description = post.description,
        tags = post.tags ?? [],
        images = post.images ?? [];
}
