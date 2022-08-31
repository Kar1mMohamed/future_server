import 'dart:io';
import 'dart:typed_data';

class FutureFile {
  FutureFile(this.file, this.request);
  final File file;
  final HttpRequest request;
  Future<Uint8List> getBytes() => file.readAsBytes();
  Future<String> getString() => file.readAsString();

  Future sendFile() async {
    return await file.openRead().pipe(request.response);
  }
}
