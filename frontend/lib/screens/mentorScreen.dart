import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:device_preview/device_preview.dart';



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      home: const SessionFeedbackReport(),
    );
  }
}

class SessionFeedbackReport extends StatelessWidget {
  const SessionFeedbackReport({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f7f7),
      appBar: AppBar(
        backgroundColor: const Color(0xff20a845),
        elevation: 4,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 30,
          ),
        ),
        title: const Text(
          "Session Feedback Report1111",
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              overallRatingCard(),

              const SizedBox(height: 20),

              suggestionsCard(),

              const SizedBox(height: 20),

              responseRateCard(),

              const SizedBox(height: 26),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff20a845),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Return to Home",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

Widget overallRatingCard() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(
      vertical: 26,
      horizontal: 18,
    ),
    decoration: cardDecoration(),
    child: Column(
      children: [
        const Text(
          "Overall Rating",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "4.5",
              style: TextStyle(
                color: Color(0xff14973a),
                fontSize: 58,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 14),
            Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                "/ 5 stars",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            if (index < 4) {
              return const Icon(
                Icons.star,
                color: Colors.orange,
                size: 40,
              );
            } else {
              return const Icon(
                Icons.star_half,
                color: Colors.orange,
                size: 40,
              );
            }
          }),
        ),

        const SizedBox(height: 18),

        const Text(
          "Based on 15 responses",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

Widget suggestionsCard() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: cardDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Suggestions for Improvement",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 22),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          decoration: BoxDecoration(
            color: const Color(0xfffbfdfc),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.grey.shade300,
            ),
          ),
          child: const Column(
            children: [
              SuggestionPoint(
                text: "Add more practical examples",
              ),

              Divider(height: 34),

              SuggestionPoint(
                text: "Increase interaction time with students",
              ),

              Divider(height: 34),

              SuggestionPoint(
                text: "Provide additional resources after class",
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class SuggestionPoint extends StatelessWidget {
  final String text;

  const SuggestionPoint({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 6,
          backgroundColor: Color(0xff14973a),
        ),

        const SizedBox(width: 18),

        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

Widget responseRateCard() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    decoration: cardDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Response Rate",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Container(
              height: 95,
              width: 95,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xffe8f8e9),
                border: Border.all(
                  color: const Color(0xff14973a),
                  width: 6,
                ),
              ),
              child: const Center(
                child: Text(
                  "90%",
                  style: TextStyle(
                    color: Color(0xff14973a),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 28),

            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "15 / 16",
                    style: TextStyle(
                      color: Color(0xff14973a),
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 4),

                  Text(
                    "students submitted feedback",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

BoxDecoration cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(
      color: Colors.grey.shade300,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.10),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
}