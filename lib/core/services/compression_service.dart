import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../config/constants.dart';

/// Servicio para comprimir imágenes antes de subirlas a Storage
/// Reduce el tamaño de las imágenes manteniendo calidad aceptable
class CompressionService {
  /// Comprime una imagen a formato JPEG
  /// [file] - Archivo de imagen original
  /// Retorna el archivo comprimido
  Future<File> compressImage(File file) async {
    try {
      // Obtener directorio temporal
      final tempDir = await getTemporaryDirectory();
      final targetPath = path.join(
        tempDir.path,
        '${DateTime.now().millisecondsSinceEpoch}_compressed.jpg',
      );

      // Comprimir imagen
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: AppConstants.imageCompressionQuality,
        minWidth: AppConstants.imageMaxWidth,
        minHeight: AppConstants.imageMaxHeight,
        format: CompressFormat.jpeg,
      );

      if (compressedFile == null) {
        if (kDebugMode) {
          print('⚠️ No se pudo comprimir, usando archivo original');
        }
        return file;
      }

      final originalSize = await file.length();
      final compressedSize = await compressedFile.length();
      final reduction = ((originalSize - compressedSize) / originalSize * 100)
          .toStringAsFixed(1);

      if (kDebugMode) {
        print('✅ Imagen comprimida:');
        print('   Original: ${_formatBytes(originalSize)}');
        print('   Comprimida: ${_formatBytes(compressedSize)}');
        print('   Reducción: $reduction%');
      }

      return File(compressedFile.path);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al comprimir imagen: $e');
      }
      // Si falla la compresión, devolver archivo original
      return file;
    }
  }

  /// Comprime múltiples imágenes en paralelo
  /// [files] - Lista de archivos a comprimir
  /// Retorna lista de archivos comprimidos
  Future<List<File>> compressMultipleImages(List<File> files) async {
    try {
      final compressionFutures = files
          .map((file) => compressImage(file))
          .toList();
      final compressedFiles = await Future.wait(compressionFutures);

      if (kDebugMode) {
        print('✅ ${compressedFiles.length} imágenes comprimidas');
      }

      return compressedFiles;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al comprimir múltiples imágenes: $e');
      }
      // Si falla, devolver archivos originales
      return files;
    }
  }

  /// Comprime una imagen desde bytes (útil para imágenes de cámara)
  /// [bytes] - Bytes de la imagen
  /// [fileName] - Nombre del archivo
  /// Retorna el archivo comprimido
  Future<File> compressImageFromBytes(List<int> bytes, String fileName) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final originalPath = path.join(tempDir.path, fileName);
      final targetPath = path.join(
        tempDir.path,
        '${DateTime.now().millisecondsSinceEpoch}_compressed.jpg',
      );

      // Guardar bytes en archivo temporal
      final originalFile = File(originalPath);
      await originalFile.writeAsBytes(bytes);

      // Comprimir
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        originalPath,
        targetPath,
        quality: AppConstants.imageCompressionQuality,
        minWidth: AppConstants.imageMaxWidth,
        minHeight: AppConstants.imageMaxHeight,
        format: CompressFormat.jpeg,
      );

      if (compressedFile == null) {
        return originalFile;
      }

      return File(compressedFile.path);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al comprimir desde bytes: $e');
      }
      // Crear archivo temporal con los bytes originales
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(path.join(tempDir.path, fileName));
      await tempFile.writeAsBytes(bytes);
      return tempFile;
    }
  }

  /// Redimensiona una imagen a dimensiones específicas
  /// [file] - Archivo de imagen
  /// [width] - Ancho objetivo
  /// [height] - Alto objetivo
  /// Retorna el archivo redimensionado
  Future<File> resizeImage({
    required File file,
    required int width,
    required int height,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath = path.join(
        tempDir.path,
        '${DateTime.now().millisecondsSinceEpoch}_resized.jpg',
      );

      final resizedFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 85,
        minWidth: width,
        minHeight: height,
        format: CompressFormat.jpeg,
      );

      if (resizedFile == null) {
        return file;
      }

      if (kDebugMode) {
        print('✅ Imagen redimensionada a ${width}x$height');
      }

      return File(resizedFile.path);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al redimensionar imagen: $e');
      }
      return file;
    }
  }

  /// Formatea bytes a formato legible (KB, MB)
  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Limpia archivos temporales de compresión
  Future<void> cleanTemporaryFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();

      int deleted = 0;
      for (final file in files) {
        if (file is File &&
            (file.path.contains('compressed') ||
                file.path.contains('resized'))) {
          await file.delete();
          deleted++;
        }
      }

      if (kDebugMode && deleted > 0) {
        print('✅ Limpiados $deleted archivos temporales');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al limpiar archivos temporales: $e');
      }
    }
  }
}
