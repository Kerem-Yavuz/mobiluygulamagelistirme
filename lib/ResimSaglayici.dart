import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ResimSaglayici {
  Future<Uint8List?> fetchImage(int type) async {
    try {
      final uri;
      if(type == 1)// i added if statement here because if we need any other images we can add the api here and call easily with type variable
        {
          uri = Uri.parse('https://cdn-icons-png.flaticon.com/512/1997/1997401.png');
        }
      else
        {
          throw Exception("Unkown Type");
        }
      print("API isteği yapılıyor: $uri");

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        print("Resim başarıyla alındı");
        return response.bodyBytes;
      } else {
        throw Exception('Resim yüklenemedi');
      }
    } catch (e) {
      print("Hata: $e");
      return null;
    }
  }
}
