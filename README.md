YKImageCacher
=============
YKImageCacher can help you to cache and manage the image by image's url for your APP. What's more, you can set the appointed cache directory, manually clear the caches.

---
##Usage#
See the code snippet below for an example of how to cache an image with the image url. There is also a simple demo app within the project.

1. Determine whether has caced the image by it's url
2. If has done, get the caced image data, otherwise add the image cached task

```Obj-c
	UIImageView *imgView = …
	NSURL imgUrl = [NSURL URLWithString:@"https://github.com/fluidicon.png"]
	
 	if (![[YKImageCacher sharedCacher] hasCachedImage:imgUrl]) {		
 	
 		[[YKImageCacher sharedCacher] addImageCachedTask:imgUrl withFinishedHandler:^(NSURL *imageURL){

            NSData *imageData = [[YKImageCacher sharedCacher] dataOfCachedImage:imageURL];
            [imgView setImage:[UIImage imageWithData:imageData]];

        }];

    }else{

        NSData *imageData = [[YKImageCacher sharedCacher] dataOfCachedImage:imgUrl];
        [imgView setImage:[UIImage imageWithData:imageData]];

    }
```
