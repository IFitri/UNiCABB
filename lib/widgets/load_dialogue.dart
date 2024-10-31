import 'package:flutter/material.dart';

class loadDialogue extends StatelessWidget
{
  String messageText;

  loadDialogue({super.key, required this.messageText});

  @override
  Widget build(BuildContext context)
  {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      backgroundColor: Colors.black87,
      child: Container(
        margin: EdgeInsets.all(15),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [

                const SizedBox(width: 5,),

                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),

                const SizedBox(width: 8,),

                Text(
                  messageText,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
          ],
        ),
        ),
      ),
    );
  }
}