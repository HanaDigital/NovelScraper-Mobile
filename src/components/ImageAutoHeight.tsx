import React, { useState } from 'react';
import { Image } from 'react-native';

const ImageAutoHeight = (props: any) => {
	var propsImageWidth: any, propsImageHeight: any, imageUri: any;
	if (props.style.length) {
		propsImageWidth = props.style[props.style.length - 1].width;
		propsImageHeight = props.style[props.style.length - 1].height;
	} else {
		propsImageWidth = props.style.width;
		propsImageHeight = props.style.height;
	}

	const [ImageHeight, setImageHeight] = useState(propsImageHeight);

	if (propsImageHeight == 'auto') {
		imageUri = props.source.uri ? props.source.uri : Image.resolveAssetSource(props.source).uri;
		Image.getSize(imageUri, (imgWidth, imgHeight) => {
			if (isNaN(propsImageWidth)) propsImageWidth = imgWidth;
			setImageHeight((imgHeight * (propsImageWidth)) / imgWidth)
		});
	}

	return (<Image {...props} style={[props.style, {
		height: ImageHeight,
	}]} />)
}

export default ImageAutoHeight;
