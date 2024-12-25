import 'package:flutter/material.dart';

class DietModel {
  String name;
  String iconPath;
  String level;
  String duration;
  String calorie;
  Color boxColor;
  bool viewIsSelected;

  DietModel(
      {required this.name,
      required this.iconPath,
      required this.level,
      required this.duration,
      required this.calorie,
      required this.boxColor,
      required this.viewIsSelected});

  static List<DietModel> getDiets() {
    List<DietModel> diets = [];

    diets.add(DietModel(
        name: 'Bowl Food Noodle',
        iconPath: 'assets/icons/salad.svg',
        level: 'Easy',
        duration: '30mins',
        calorie: '180kCal',
        viewIsSelected: true,
        boxColor: const Color.fromARGB(255, 255, 234, 198)));

    diets.add(DietModel(
        name: 'Bibimbub Food',
        iconPath: 'assets/icons/pancakes.svg',
        level: 'Medium',
        duration: '20mins',
        calorie: '230kCal',
        viewIsSelected: false,
        boxColor: const Color.fromARGB(255, 255, 229, 244)));

    diets.add(DietModel(
        name: 'Chow Food',
        iconPath: 'assets/icons/orange.svg',
        level: 'Easy',
        duration: '20mins',
        calorie: '200kCal',
        viewIsSelected: false,
        boxColor: const Color.fromARGB(255, 231, 255, 198)));

    return diets;
  }
}
