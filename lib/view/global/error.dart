import 'package:flutter/material.dart';

import '../../common/utils.dart';
import '../../main.dart';
import '../home/home.dart';


class ErrorMessage extends StatelessWidget
{
  const ErrorMessage({
    super.key,
    this.message,
    this.textColor = Utils.white
  });
  final String? message;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Oups, une erreur est survenue. 😥',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: textColor
            ),
          ),
          ...[
            if(message != null)
              Text(message!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15),),
          ],
          Text(
            'Veuillez vérifier votre connexion Internet et réessayer.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 15,
                color: textColor
            ),
          ),
          Text(
            "Si l'erreur persiste, merci de contacter les développeurs sur PlayStore",
            textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 15,
                  color: textColor
              )
          ),
          IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Main()),
                );
              },
              color: Colors.white,
              icon: const Icon(Icons.refresh)
          )
        ],
      ),
    );
  }
}
