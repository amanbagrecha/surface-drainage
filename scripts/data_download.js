// DOWNLOAD DATA FROM GOOGLE EARTH ENGINE

// DOWNLOAD NASA SRTM Digital Elevation 30m

var dataset = ee.Image("USGS/SRTMGL1_003")
var elevation = dataset.select('elevation');


Export.image.toDrive({
    image: dataset,
    description: 'SRTM Digital Elevation Data 30 m',
    scale: 30,
    region: table1
  });


// DOWNLOAD Sentinel-2 MSI: MultiSpectral Instrument, Level-1C

// var table = Table users/jainaman588/bbmpwards_UTM
var img1= ee.Image('COPERNICUS/S2/20200124T051109_20200124T051244_T43PGQ');

var viz = {
  min: 779.5,
  max: 1936.5,
  bands: ['B4', 'B3', 'B2']
};
Map.addLayer(img1, viz, 'SENTINEL-21', true);

Export.image.toDrive({
  image: img1,
  description: 'Sentinel_2_blr',
  scale: 10,
  region: table
});
