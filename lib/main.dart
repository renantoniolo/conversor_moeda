import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance/quotations?key=78286f67";

// Inicia o aplicativo
// MaterialApp contem todos os widget necessários para montar um app
void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(hintColor: Colors.amber, primaryColor: Colors.white),
  ));
}


class Teste extends StatefulWidget {
  @override
  _TesteState createState() => _TesteState();
}

class _TesteState extends State<Teste> {
  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}

// Widget que tenha estado mutável (pode sofrer alteração)
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  TextEditingController realController = TextEditingController();
  TextEditingController dolarController = TextEditingController();
  TextEditingController euroController = TextEditingController();

  double dolar;
  double euro;

  // metodo onChanged, para retornar a cotação atual Real
  void _realChange(String text) {
    if (text.isEmpty) _clearControllerText();
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  // metodo onChanged, para retornar a cotação atual Dolar
  void _dolarChange(String text) {
    if (text.isEmpty) _clearControllerText();
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  // metodo onChanged, para retornar a cotação atual Euro
  void _euroChange(String text) {
    if (text.isEmpty) _clearControllerText();
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  // Meotodo para limpar os TextField`s
  void _clearControllerText() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

// Designer da view iniciada sobre um Scaffold
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Conversor Moeda"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              break;
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  "Carregando Dados...",
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                  textAlign: TextAlign.center,
                ),
              );
              break;

            default:
              if (snapshot.hasError) {
                Center(
                  child: Text(
                    "Erro ao carregar os dados.",
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(
                        Icons.monetization_on,
                        size: 150,
                        color: Colors.amber,
                      ),
                      Divider(),
                      buildTextField(
                          "Reais", "R\$ ", realController, _realChange),
                      Divider(),
                      buildTextField(
                          "Dolares", "US\$ ", dolarController, _dolarChange),
                      Divider(),
                      buildTextField(
                          "Euros", "€ ", euroController, _euroChange),
                      Divider(),
                      Container(
                        height: 45.0,
                        margin: new EdgeInsets.symmetric(vertical: 10.0),
                        child: RaisedButton(
                          color: Colors.amber,
                          textColor: Colors.black,
                          child: Text(
                            "Limpar",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            // metodo para limpar os TextField`s
                            _clearControllerText();
                          },
                        ),
                      )
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }

  // Metodo para retornar uma widget `TextField`
  Widget buildTextField(
      String label, String prefix, TextEditingController ctrl, Function func) {
        // Retorna um widget TextField
    return TextField(
        controller: ctrl,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        onChanged: func,
        decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: Colors.amber,
            ),
            border: OutlineInputBorder(),
            prefixText: prefix),
        textAlign: TextAlign.start,
        cursorColor: Colors.white,
        style: TextStyle(color: Colors.amber));
  }
}

// Metodo para buscar cotaçoes atuais de cada moeda  
Future<Map> getData() async {
  // busca na requesiçao via rest Http
  http.Response response = await http.get(request);
  // retorna a chamada em json
  return json.decode(response.body);
}
