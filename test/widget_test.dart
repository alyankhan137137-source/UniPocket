import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipocket/widgets/custom_button.dart';
import 'package:unipocket/widgets/custom_input.dart';
import 'package:unipocket/constants/app_colors.dart';

void main() {
  group('Custom Widgets Rendering Tests', () {
    testWidgets('CustomButton renders correct label and variant', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              label: 'Submit',
              onPressed: () {},
              variant: ButtonVariant.primary,
            ),
          ),
        ),
      );

      // Verify the label text exists
      expect(find.text('Submit'), findsOneWidget);
      
      // Verify button uses the primary color
      final button = tester.widget<Ink>(find.byType(Ink));
      final decoration = button.decoration as BoxDecoration;
      expect(decoration.color, AppColors.primary);
    });

    testWidgets('CustomInput displays error on empty validation', (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: CustomInput(
                label: 'Title',
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
            ),
          ),
        ),
      );

      // Trigger validation
      formKey.currentState!.validate();
      await tester.pump();

      // Check for error text
      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('CustomButton shows loading indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              label: 'Wait',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Label should be replaced by spinner
      expect(find.text('Wait'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
