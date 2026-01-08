
import 'package:flutter/material.dart';

class AdminWalkInBilling extends StatelessWidget {
  const AdminWalkInBilling({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'New Walk-in Bill',
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 30, left: 20),
          child: Column(
            children: [
               Wrap(
          runSpacing: 20.0,
          spacing: 30.0,
          children: [
            Container(
              height: screenHeight * 0.3,
              width: screenWidth * 0.45,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Color(0xFFD6D6D6)),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20, top: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customer',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 22),
                    SearchInput(
                      textController: TextEditingController(),
                      hintText: 'Search existing customer....',
                    ),
                    const SizedBox(height: 30),

                    Row(
                      children: [
                        const Text(
                          '+',
                          style: TextStyle(color: Color(0xFF8B48FF)),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Add New Customer',
                          style: TextStyle(
                            color: Color(0xFF8B48FF),
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
      height: screenHeight * 0.3,
      width: screenWidth * 0.45,

      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xFFD6D6D6)),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 15, left: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Services',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 440),
                const Text('+', style: TextStyle(color: Color(0xFF8B48FF))),
                const SizedBox(width: 10),
                const Text(
                  'Add',
                  style: TextStyle(color: Color(0xFF8B48FF), fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 15),

            SizedBox(
              width: screenWidth * 0.41,
              height: screenHeight * 0.09,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(13),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:const Column(
                    spacing: 15,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Classic Hair cur',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text('30 mins'),
                              ],
                            ),
                          ),
                          
                          Text(
                            ' \$30',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: screenWidth * 0.41,
              height: screenHeight * 0.09,
              child:Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(13),
                child: const Padding(
                  padding:  EdgeInsets.all(8.0),
                  child: Column(
                    spacing: 15,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Prenimum Beared Trim',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text('20 mins'),
                              ],
                            ),
                          ),
                          Text(
                            ' \$60',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
          Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8F48FF), // Lighter Purple
            Color(0xFF722CE8), // Darker Purple
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header
          const Text(
            "Bill Summary",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 20),

          //  Summary Rows
          _buildSummaryRow("Subtotal", "\$45.00"),
          const SizedBox(height: 12),
          _buildSummaryRow("Tax (8%)", "\$3.60"),
          const SizedBox(height: 12),
          _buildSummaryRow("Discount", "\$0.00"),

          const SizedBox(height: 20),

          //  Divider Line (White with Opacity)
          const Divider(color: Color(0x33FFFFFF), thickness: 1, height: 1),

          const SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Total",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                "\$48.60",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    ),

            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {},

                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF7F3DFF), // Purple Border
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "Save as Draft",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7F3DFF), // Purple Text
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7F3DFF),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7F3DFF),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "Finalize Bill",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // White Text
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
              
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildSummaryRow(String label, String amount) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 15,
          color: Colors.white,
          fontWeight: FontWeight.w400,
        ),
      ),
      Text(
        amount,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

class SearchInput extends StatelessWidget {
  final TextEditingController textController;
  final String hintText;
  const SearchInput({
    required this.textController,
    required this.hintText,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double screenWdith = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight * 0.07,
      width: screenWdith * 0.4,
      decoration: BoxDecoration(),
      child: TextField(
        controller: textController,
        onChanged: (value) {},

        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          hintText: hintText,
          hintStyle: TextStyle(color: Color(0xFF9E9E9E)),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10.0,
            horizontal: 20.0,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF9E9E9E), width: 1.0),
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 2.0),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
    );
  }
}