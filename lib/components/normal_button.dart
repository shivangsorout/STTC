import 'package:flutter/material.dart';

class NormalButton extends StatelessWidget {
  final String title;
  final Function() onPressed;

  NormalButton({
    @required this.title,
    @required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: new MaterialButton(
        disabledColor: Colors.grey[800],
        color: Theme.of(context).colorScheme.secondary,
        textColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
