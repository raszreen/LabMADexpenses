import 'dart:convert';
import 'package:http/http.dart' as http;

class RequestController {
  String path;
  String server;
  http.Response? _res;
  final Map<dynamic, dynamic> _body = {};
  final Map<String,String> _headers = {};
  dynamic _resultData;

  RequestController({required this.path, this.server = "http://172.20.10.4"});
  setBody(Map<String, dynamic> data) {
    _body.clear();
    _body.addAll(data);
    _headers["Content-Type"] = "application/json; charset=UTF-8";
  }
  Future<void> post() async {
    _res = await http.post(
      Uri.parse(server + path),
      headers: _headers,
      body: jsonEncode(_body),
    );
    if (_res?.statusCode == 200) {
      _parseResult();
    } else {
      print("HTTP request failed with status code: ${_res?.statusCode}");
    }
  }
  Future<void> get() async {
    _res = await http.get(
        Uri.parse(server + path),
        headers: _headers,
    );
    _parseResult();
  }

  Future<void> put() async{
    _res = await http.put(
      Uri.parse(server + path),
      headers: _headers,
      body: jsonEncode(_body),
    );
    if (_res?.statusCode == 200) {
      _parseResult();
    } else {
      print("HTTP request failed with status code: ${_res?.statusCode}");
    }
  }

  Future<void> delete() async {

    // Make a DELETE request to the server
    _res = await http.delete(
      Uri.parse(server + path),
      headers: _headers,
      body: jsonEncode(_body),
    );

    if (_res?.statusCode == 200) {
      _parseResult();
    } else {
      print("HTTP request failed with status code: ${_res?.statusCode}");
    }
  }

  void _parseResult() {
    // parser result into json structure if possible
    try{
      print("raw response:${_res?.body}");
      _resultData = jsonDecode(_res?.body?? "");
    }catch(ex){
      //otherwise the response body will be stored as is
      _resultData = _res?.body;
      print("exception in http result parsing ${ex}");
    }
  }
  dynamic result() {
    return _resultData;
  }
  int status() {
    return _res?.statusCode ?? 0;
  }
}