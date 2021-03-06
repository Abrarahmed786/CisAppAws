import 'package:cisapp_aws/generate_image_url.dart';
import 'package:cisapp_aws/get_image_permission.dart';
import 'package:cisapp_aws/upload_file.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:image_picker/image_picker.dart';

import 'attachment_modal.dart';

typedef Future<bool> OnSaveImage(String url);

enum Source { GALLERY, CAMERA, NONE }

class SingleImagePicker {
  final PickImageSource pickImageSource;
  final Function(String path) onImagePicked;
  final Function(String downloadUrl) onImageSuccessfullySaved;
  final OnSaveImage onSaveImage;
  final Function(String message) onImageUploadFailed;

  var path;

  SingleImagePicker({
    this.pickImageSource = PickImageSource.both,
    required this.onImagePicked,
    required this.onSaveImage,
    required this.onImageSuccessfullySaved,
    required this.onImageUploadFailed,
  }) {
    throw UnimplementedError();
  }

  final ImagePicker imagePicker = ImagePicker();

  Future<void> pickImage(context) async {
    try {
      ImageSource imageSource;

      if (pickImageSource == PickImageSource.both) {
        Size size = MediaQuery.of(context).size;
        var sheet = AddAttachmentModalSheet(size);
        await showModalBottomSheet(
          context: context,
          builder: (context) => sheet,
          isScrollControlled: true,
        );

        if (sheet.source == Source.CAMERA) {
          imageSource = ImageSource.camera;
        } else if (sheet.source == Source.GALLERY) {
          imageSource = ImageSource.gallery;
        } else {
          return;
        }
      } else if (pickImageSource == PickImageSource.camera) {
        imageSource = ImageSource.camera;

        GetImagePermission getPermission = GetImagePermission.camera();
        await getPermission.getPermission(context);

        if (getPermission.granted == false) {
          //Permission is not granted
          return;
        }
      } else if (pickImageSource == PickImageSource.gallery) {
        imageSource = ImageSource.gallery;

        GetImagePermission getPermission = GetImagePermission.gallery();
        await getPermission.getPermission(context);

        if (getPermission.granted == false) {
          //Permission is not granted
          return;
        }
      } else {
        return;
      }

      PickedFile? image = await imagePicker.getImage(source: imageSource);

      if (image != null) {
        onImagePicked?.call(image.path);

        String fileExtension = path.extension(image.path);

        GenerateImageUrl generateImageUrl = GenerateImageUrl();
        await generateImageUrl.call(fileExtension);

        Uri uploadUrl;
        if (generateImageUrl.isGenerated != null &&
            generateImageUrl.isGenerated) {
          uploadUrl = generateImageUrl.uploadUrl as Uri;
        } else {
          throw generateImageUrl.message;
        }

        UploadFile uploadFile = UploadFile();
        await uploadFile.call(uploadUrl, image);

        if (uploadFile.isUploaded != null && uploadFile.isUploaded) {
          bool isSaved = await onSaveImage(generateImageUrl.downloadUrl);
          if (isSaved) {
            onImageSuccessfullySaved(generateImageUrl.downloadUrl);
          } else {
            throw "Failed to save image";
          }
        } else {
          throw uploadFile.message;
        }
      }
    } catch (e) {
      onImageUploadFailed(e.toString());
    }
  }
}

class PickImageSource {
  static var both;
  static Object camera = camera;
  static Object gallery = gallery;
}
