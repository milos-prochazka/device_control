// ignore_for_file:  unnecessary_this

import 'package:flutter/widgets.dart';

extension TextEditingExtension on TextEditingController 
{
  void setIfChanged(String value) 
  {
    if (value != this.text) 
    {
      this.text = value;
    }
  }
}