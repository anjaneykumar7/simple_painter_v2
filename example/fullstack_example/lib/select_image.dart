import 'package:flutter/material.dart';

class SelectImageDialog extends StatelessWidget {
  const SelectImageDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const imageLinks = [
      'https://picsum.photos/200',
      'https://picsum.photos/201',
      'https://picsum.photos/202',
      'https://picsum.photos/203',
      'https://picsum.photos/204',
      'https://picsum.photos/205',
      'https://picsum.photos/206',
      'https://picsum.photos/207',
      'https://picsum.photos/208',
      'https://picsum.photos/209',
      'https://picsum.photos/210',
      'https://picsum.photos/211',
      'https://picsum.photos/212',
      'https://picsum.photos/213',
      'https://picsum.photos/214',
      'https://picsum.photos/215',
      'https://picsum.photos/216',
      'https://picsum.photos/217',
      'https://picsum.photos/218',
      'https://picsum.photos/219',
      'https://picsum.photos/220'
    ];
    return AlertDialog(
      title: const Text('Select Image'),
      content: imageLinks.isEmpty
          ? const Text('No images')
          : FractionallySizedBox(
              heightFactor: 0.5,
              child: SingleChildScrollView(
                child: Wrap(
                  children: [
                    for (final imageLink in imageLinks)
                      InkWell(
                        onTap: () => Navigator.pop(context, imageLink),
                        child: FractionallySizedBox(
                          widthFactor: 1 / 4,
                          child: Image.network(imageLink),
                        ),
                      ),
                  ],
                ),
              ),
            ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        )
      ],
    );
  }
}
