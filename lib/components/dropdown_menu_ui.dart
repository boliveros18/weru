import 'package:flutter/material.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:weru/components/button_ui.dart';
import 'package:weru/components/text_field_ui.dart';

class DropdownMenuUi extends StatefulWidget {
  final List<DropDownValueModel> list;
  final String title;
  final Function(String) onConfirm;
  final bool textfield;
  final String hint;

  const DropdownMenuUi(
      {super.key,
      required this.list,
      required this.title,
      required this.onConfirm,
      this.textfield = false,
      this.hint = ""});

  @override
  State<DropdownMenuUi> createState() => _DropdownMenuUiState();
}

class _DropdownMenuUiState extends State<DropdownMenuUi> {
  String selectedId = "";
  final SingleValueDropDownController _dropdownController =
      SingleValueDropDownController(
    data: null,
  );

  @override
  void dispose() {
    _dropdownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          "1. Selecciona o busca un(a) ${widget.title.toLowerCase()}:",
          style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
        ),
        const SizedBox(height: 20),
        DropDownTextField(
          controller: _dropdownController,
          textFieldDecoration: InputDecoration(
            labelText: "Selecciona un ítem (${widget.list.length})",
            labelStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
            border: OutlineInputBorder(),
          ),
          enableSearch: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Este campo es requerido";
            }
            return null;
          },
          dropDownList: widget.list,
          listTextStyle: const TextStyle(color: Colors.black, fontSize: 15),
          dropDownItemCount: 5,
          onChanged: (dropDownValue) {
            if (dropDownValue is DropDownValueModel) {
              selectedId = dropDownValue.value ?? "";
            } else {
              selectedId = "";
            }
          },
        ),
        const SizedBox(height: 20),
        widget.textfield ? TextFieldUi(hint: widget.hint) : Container(),
        widget.textfield ? const SizedBox(height: 20) : Container(),
        Row(
          children: [
            Spacer(),
            Expanded(
              child: ButtonUi(
                value: "Agregar",
                onClicked: () {
                  if (selectedId.isNotEmpty) {
                    widget.onConfirm(selectedId);
                    _dropdownController.setDropDown(null);
                  }
                },
                color: const Color(0xff4caf50),
                borderRadius: 2,
                fontSize: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
