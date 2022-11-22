import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:sohal_kutuphane/backend/image.dart';

class ImageSlider extends StatelessWidget {
  List<String> imageList;
  ImageSlider({Key? key, required this.imageList}) : super(key: key);

  final CarouselController controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    var c = MediaQuery.of(context).size;
    return Column(
      children: [
        CarouselSlider.builder(
          carouselController: controller,
          itemCount: imageList.length,
          options: CarouselOptions(
            enlargeCenterPage: true,
            height: (c.width < 500) ? c.width - 100 : 800,
            autoPlay: true,
          ),
          itemBuilder: (context, index, realIndex) => Card(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            clipBehavior: Clip.antiAlias,
            child: Container(
              width: MediaQuery.of(context).size.width,
              //color: Colors.green,
              child:
                  //borderRadius: BorderRadius.,
                  Ink.image(
                //colorFilter:const ColorFilter.mode(Colors.grey, BlendMode.modulate),
                //*image: NetworkImage(ServerURL.normalized(imageList[index])),
                image: CachedNetworkImageProvider(
                  ServerURL.normalized(imageList[index]),
                ),

                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                //enableFeedback: false,
                splashRadius: 0.1,
                onPressed: () {
                  controller.previousPage(
                      duration: const Duration(milliseconds: 300));
                },
                icon: const Icon(Icons.navigate_before_outlined)),
            IconButton(
                //enableFeedback: false,
                splashRadius: 0.1,
                onPressed: () {
                  controller.nextPage(
                      duration: const Duration(milliseconds: 300));
                },
                icon: const Icon(Icons.navigate_next_outlined)),
          ],
        ),
      ],
    );
  }
}
