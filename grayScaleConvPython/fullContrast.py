from PIL import Image, ImageFilter, ImageOps

try:
	# Load an image from the hard drive
	original = Image.open("test11.png")
	# Blur the image
	blurred = original.filter(ImageFilter.BLUR)
	# Display both images
	#original.show()
	#blurred.show()
	# save the new image
	#blurred.save("blurred.png")
	con = original.filter(ImageFilter.CONTOUR)
	#im.save("lenna" + ".jpg")
	#con.show()
	#print(original.format, original.size, original.mode)
	
	# split the image into individual bands
	source = original.split()
	
	#print ("split ok")
	R, G, B = 0, 1, 2

# select regions where red is less than 100
	mask = source[R].point(lambda i: i < 100 and 255)

# process the green band
	out = source[G].point(lambda i: i * 0.7)
	#print ("green band ok")
	
# paste the processed band back, but only where red was < 100
	source[G].paste(out, None, mask)
	#print ("paste ok")
	
# build a new multiband image
	newIm = Image.merge(original.mode, source)
	#newIm.show()
	
	invert = ImageOps.invert(original)
	#invert.show()
	#r, g, b = original.split()
	r, g, b = invert.split()
	
	#print("invert done")
	#print r
	g = r
	b = r
	
	redChannel = r.point(lambda i: i*0 if i < 20 else i)
	greenChannel = g.point(lambda i: i*0 if i < 20 else i)
	blueChannel = b.point(lambda i: i*0 if i < 20 else i) 	 	
	#redChannel = r.point(lambda i: i * 0.7)
	redChannel = r.point(lambda i: i/i if i > 200 else i)
	greenChannel = g.point(lambda i: i/i if i > 200 else i)
	blueChannel = b.point(lambda i: i/i if i > 200 else i)
	
	redChannel = r.point(lambda i: (i-30)/(200-30) if i > 100 and i < 200 else i)
	greenChannel = g.point(lambda i: (i-30)/(200-30) if i > 100 and i < 200 else i)
	blueChannel = b.point(lambda i: (i-30)/(200-30) if i > 100 and i < 200 else i)
	
	
	#light sensitive area needs better conversion
	
	#works for mountains, dark spectrum, should be adjustable
	#redChannel = r.point(lambda i: (i-30)/(200-30) if i > 130 and i < 200 else i)
	#greenChannel = g.point(lambda i: (i-30)/(200-30) if i > 130 and i < 200 else i)
	#blueChannel = b.point(lambda i: (i-30)/(200-30) if i > 130 and i < 200 else i)
	
	merg = Image.merge("RGB", (redChannel, greenChannel, blueChannel))
	merg.show()
	Gausblur = merg.filter(ImageFilter.GaussianBlur(1))
	Gausblur = ImageOps.invert(Gausblur)
	Gausblur.show()
	#Gausblur.save("test3Done.png")
	#print(source[0])
	#print(mask)
	#set all channel to the same red value channel
	
except:
	print "Unable to load image"