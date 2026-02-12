import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'compression_service.dart';

/// Servicio para gestionar el almacenamiento en Firebase Storage
/// Incluye compresión automática de imágenes antes de subir
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final CompressionService _compressionService = CompressionService();
  final Uuid _uuid = const Uuid();

  /// Sube una imagen con compresión automática
  /// [file] - Archivo de imagen a subir
  /// [path] - Ruta en Storage (ej: 'vehicles/ABC123')
  /// Retorna la URL de descarga
  Future<String> uploadImage({required File file, required String path}) async {
    try {
      // Comprimir la imagen antes de subir
      final compressedFile = await _compressionService.compressImage(file);

      // Generar nombre único con UUID
      final fileName = '${_uuid.v4()}.jpg';
      final fullPath = '$path/$fileName';

      // Referencia al archivo en Storage
      final ref = _storage.ref().child(fullPath);

      // Metadata para la imagen
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'uploadedAt': DateTime.now().toIso8601String()},
      );

      // Subir archivo comprimido
      final uploadTask = ref.putFile(compressedFile, metadata);

      // Esperar a que termine la subida
      final snapshot = await uploadTask;

      // Obtener URL de descarga
      final downloadUrl = await snapshot.ref.getDownloadURL();

      if (kDebugMode) {
        print('✅ Imagen subida: $downloadUrl');
      }

      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al subir imagen: $e');
      }
      throw Exception('Error al subir imagen: $e');
    }
  }

  /// Sube múltiples imágenes en paralelo
  /// [files] - Lista de archivos a subir
  /// [path] - Ruta base en Storage
  /// Retorna lista de URLs de descarga
  Future<List<String>> uploadMultipleImages({
    required List<File> files,
    required String path,
  }) async {
    try {
      final uploadFutures = files
          .map((file) => uploadImage(file: file, path: path))
          .toList();

      final urls = await Future.wait(uploadFutures);

      if (kDebugMode) {
        print('✅ ${urls.length} imágenes subidas correctamente');
      }

      return urls;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al subir múltiples imágenes: $e');
      }
      throw Exception('Error al subir imágenes: $e');
    }
  }

  /// Sube un documento (PDF, etc.)
  /// [file] - Archivo a subir
  /// [path] - Ruta en Storage
  /// [contentType] - Tipo MIME del archivo (ej: 'application/pdf')
  /// Retorna la URL de descarga
  Future<String> uploadDocument({
    required File file,
    required String path,
    required String contentType,
  }) async {
    try {
      final fileName = '${_uuid.v4()}.${_getFileExtension(contentType)}';
      final fullPath = '$path/$fileName';

      final ref = _storage.ref().child(fullPath);

      final metadata = SettableMetadata(
        contentType: contentType,
        customMetadata: {'uploadedAt': DateTime.now().toIso8601String()},
      );

      final uploadTask = ref.putFile(file, metadata);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      if (kDebugMode) {
        print('✅ Documento subido: $downloadUrl');
      }

      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al subir documento: $e');
      }
      throw Exception('Error al subir documento: $e');
    }
  }

  /// Elimina un archivo de Storage
  /// [url] - URL del archivo a eliminar
  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();

      if (kDebugMode) {
        print('✅ Archivo eliminado: $url');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al eliminar archivo: $e');
      }
      throw Exception('Error al eliminar archivo: $e');
    }
  }

  /// Elimina múltiples archivos en paralelo
  /// [urls] - Lista de URLs a eliminar
  Future<void> deleteMultipleFiles(List<String> urls) async {
    try {
      final deleteFutures = urls.map((url) => deleteFile(url)).toList();
      await Future.wait(deleteFutures);

      if (kDebugMode) {
        print('✅ ${urls.length} archivos eliminados correctamente');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al eliminar múltiples archivos: $e');
      }
      throw Exception('Error al eliminar archivos: $e');
    }
  }

  /// Obtiene la extensión del archivo según el content type
  String _getFileExtension(String contentType) {
    switch (contentType) {
      case 'application/pdf':
        return 'pdf';
      case 'image/jpeg':
      case 'image/jpg':
        return 'jpg';
      case 'image/png':
        return 'png';
      default:
        return 'bin';
    }
  }

  /// Obtiene el progreso de subida de un archivo
  /// [file] - Archivo a subir
  /// [path] - Ruta en Storage
  /// Retorna un Stream con el progreso (0.0 a 1.0)
  Stream<double> uploadWithProgress({
    required File file,
    required String path,
  }) async* {
    try {
      final fileName = '${_uuid.v4()}.jpg';
      final fullPath = '$path/$fileName';
      final ref = _storage.ref().child(fullPath);

      final uploadTask = ref.putFile(file);

      await for (final snapshot in uploadTask.snapshotEvents) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        yield progress;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error en upload con progreso: $e');
      }
      throw Exception('Error al subir archivo: $e');
    }
  }
}
