# Created on: 13/03/2021 by Aman Bagrecha
# contains implementation of algorithm
# Import modules
import arcpy
import os
import numpy as np
import time


starttime= time.clock()
# specify output location
oc = os.path.join(os.getcwd(), "../output/output.gdb")
output_loc = os.path.abspath(oc)  # save location for all output


cluster_polygon_feature = 'cluster_zones_kmeans' # vector layer for zonal stats
# specify input location
ic = os.path.join(os.getcwd(), "../input/input.gdb")
input_loc =  os.path.abspath(ic) # location where input data resides


#  inputs
arcpy.env.overwriteOutput = True
SRTM_Digital_Elevation_Data_30m_tif = os.path.join(input_loc,'SRTM_Digital_Elevation_Data_30m')
Statistics_type = "MEAN"
# slope of dem
wshslope = os.path.join(input_loc, 'slope_raster_blr')

drain_slope = 0.003 

spatial_reference = "WGS 1984 UTM Zone 43N" # EPSG: 32643
# classes for coef of runoff
coef_of_runoff_classes= {'Bareland':0.6 , 'Urban': 0.9,'Forest':0.2}


roads = ['attimabe_road', 'fourth', 'Cubbon_road']

"""
LIST OF ROADS ANALYSED. Replace the `roads` list to get output for any road you want. Roads are stored inside input geodatabase. 
# ['attimabe_road', 'banashankari_50feetRoad', 'BullTempleRoad', 'Cubbon_road', 'eighteenth', 'eight', 'eighty_feet_road2', 'eighty_feet_road',
# 		'eleventh', 'fifteenth', 'fifth', 'fourth', 'fouteenth', 'gubbala_main_rd' 'KR_road', 'Mysore_Road_end', 'nineteenth', 'ninth','PatanagereRoadOne',
# 		'PatanagereRoadTwo','puttalingaiah_rd', 'Rashtreeya_VidhayalayaRoad', 'RashtreeyaVidhalayaRoad', 'second', 'seventeenth', 'seventh', 'sixteenth',
# 		'sixth', 'subramanyapuru_main_rd', 'subramanyapuru_main_rd2', 'TechRoadOne', 'TechRoadTwo','tenth','third', 'thirteenth','twentyfirst',
# 		'varsharuthu_road', 'vasanthpura_main_rd']
"""

catchment = [5] # 5 cell threshold of flow accumulation. obtained from calibrating with manual method of area determination

headers = ['road_loc','catchement','area', 'mean_slope', 'length', 'slope', 'tc', 'Intensity', 'coef_runoff', 'discharge', 'depth']
for road in roads:

	for cat in catchment:

		arcpy.env.overwriteOutput = True
		list_excel = [] # store result
		list_excel.append(road)
		list_excel.append('cat{}'.format(cat))
		design_road = os.path.join(input_loc, road)

		watershed_raster = os.path.join(input_loc,'cat{}'.format(cat))
		print(watershed_raster)
# Step 1
		
		#Name: RasterToPolygon
		#Description: Converts a raster dataset to polygon features.
		#Requirements: None
		
		outPolygons = os.path.join(output_loc,"X_RasterToPolygon")
		field = "Value"
		# Execute RasterToPolygon
		arcpy.RasterToPolygon_conversion(watershed_raster, outPolygons, "NO_SIMPLIFY", field)

		# Make a layer from the feature class
		arcpy.MakeFeatureLayer_management(outPolygons,"RasterToPolygon_lyr")


# Step 2

		# Process: Select Layer By Location
		arcpy.SelectLayerByLocation_management(in_layer="RasterToPolygon_lyr", overlap_type="INTERSECT" ,\
											   select_features=design_road, selection_type="NEW_SELECTION",invert_spatial_relationship= "NOT_INVERT")


		# Write the selected features to a new featureclass
		_selected_watersheds=os.path.join(output_loc,"X_selected_watersheds")

		arcpy.CopyFeatures_management("RasterToPolygon_lyr",_selected_watersheds )


# Step 3

		# Name: ZonalStatisticsAsTable
		# Description: Summarizes values of a raster within the zones of 
		#              another dataset and reports the results to a table.
		# Requirements: Spatial Analyst Extension

		# Import system modules
		from arcpy.sa import *

		# Set local variables
		zoneField = "Id"
		inValueRaster = SRTM_Digital_Elevation_Data_30m_tif
		_zonalStatsMean = os.path.join(output_loc,"X_zonalStatsMean")

		# Check out the ArcGIS Spatial Analyst extension license
		arcpy.CheckOutExtension("Spatial")

		# attach elevation value to each divided polygon
		# Execute ZonalStatisticsAsTable
		outZSaT = ZonalStatisticsAsTable(_selected_watersheds, zoneField, SRTM_Digital_Elevation_Data_30m_tif, 
										 _zonalStatsMean, "NODATA", "MEAN")



# Step 4

		# Name: AttributeSelection
		# Purpose: Join a table to a featureclass and select the desired attributes

		arcpy.env.qualifiedFieldNames = False
			
		# local variables
		layerName = "watershedMeanLyr" 
		infield = "OBJECTID"  
		joinfield= "OBJECTID"
		_watershed_with_mean = os.path.join(output_loc,"X_watershed_with_mean")
			
		# Create a feature layer from the vegtype featureclass
		arcpy.MakeFeatureLayer_management (_selected_watersheds,  layerName)
			
		# Join the feature layer to a table
		arcpy.AddJoin_management(in_layer_or_view=layerName, in_field=infield, join_table=_zonalStatsMean,
								 join_field=joinfield, join_type="KEEP_COMMON" )
			

		# Copy the layer to a new permanent feature class
		arcpy.CopyFeatures_management(layerName, _watershed_with_mean)

		arcpy.FeatureClassToShapefile_conversion([_watershed_with_mean],
                                         r"D:\6th_sem\final_year\arcGIS\main\watershed_shapefile")
		# Local variables:
		watershed_with_mean_Project = os.path.join(output_loc,"X_watershed_with_mean_Project")

		# Process: Project
		arcpy.Project_management(_watershed_with_mean, watershed_with_mean_Project, "PROJCS['WGS_1984_UTM_Zone_43N',GEOGCS['GCS_WGS_1984',DATUM['D_WGS_1984',SPHEROID['WGS_1984',6378137.0,298.257223563]],PRIMEM['Greenwich',0.0],UNIT['Degree',0.0174532925199433]],PROJECTION['Transverse_Mercator'],PARAMETER['False_Easting',500000.0],PARAMETER['False_Northing',0.0],PARAMETER['Central_Meridian',75.0],PARAMETER['Scale_Factor',0.9996],PARAMETER['Latitude_Of_Origin',0.0],UNIT['Meter',1.0]]", "", "GEOGCS['GCS_WGS_1984',DATUM['D_WGS_1984',SPHEROID['WGS_1984',6378137.0,298.257223563]],PRIMEM['Greenwich',0.0],UNIT['Degree',0.0174532925199433]]", "NO_PRESERVE_SHAPE", "", "NO_VERTICAL")



# Step 5

		# select intersecting watershed to contributing area
		#  finding contributing area (actual)
		a_area = []
		with arcpy.da.SearchCursor(watershed_with_mean_Project, ['Shape_Area']) as cursor:
			for row in cursor:
				a_area.append(row[0])
			print('area is: {}'.format(sum(a_area)))
		list_excel.append(sum(a_area))


# Step 6

		# cliping clustered area for calculating coef of runoff
		# Process: Clip
		# Set local variables
		in_features = os.path.join(input_loc,cluster_polygon_feature)

		clip_features = watershed_with_mean_Project
		X_clustered_design_area_clip = os.path.join(output_loc,"X_clustered_design_area_clip")
		xy_tolerance = ""

		arcpy.env.outputCoordinateSystem = arcpy.SpatialReference(spatial_reference)
		# Execute Clip
		arcpy.Clip_analysis(in_features, watershed_with_mean_Project, X_clustered_design_area_clip, xy_tolerance)


# Step 7

		# finding mean slope
		# Local variables:
		_contributing_area = watershed_with_mean_Project # contributingArea
		_contributing_area_Dissolve = os.path.join(output_loc,"X_contributing_area_Dissolve")
		Statistics_type = "MEAN"
		ZonalSt_X_contr1 = os.path.join(output_loc,"X_mean_slope_contributing_area") 

		# Process: Dissolve
		arcpy.Dissolve_management(_contributing_area, _contributing_area_Dissolve, "", "", "SINGLE_PART", "DISSOLVE_LINES")

		# Process: Zonal Statistics as Table
		arcpy.gp.ZonalStatisticsAsTable_sa(_contributing_area_Dissolve, "OBJECTID", wshslope, ZonalSt_X_contr1, "DATA", Statistics_type)


		featureclass = ZonalSt_X_contr1
		field_names = ['MEAN'] 


		# variables
		percent_slope=[]

		with arcpy.da.SearchCursor(featureclass, field_names) as cursor:
			for row in cursor:
				percent_slope.append(row[0])
			print("Mean slope of contributing area is :" +  "{}".format(sum(percent_slope)))
			list_excel.append(sum(percent_slope))



# Step 7

		# taking the road length within contributing area for **time of concentration**
		# design_road_1_Project = design_road

		xy_tolerance = ""


		Points_on_Tc = os.path.join(output_loc,"X_PointsOnLineTc")

		# we are taking the design road itself as the critical path
		arcpy.GeneratePointsAlongLines_management(design_road, Points_on_Tc, "DISTANCE", "100000 meters", "", "END_POINTS") # generate points only at the end

		from arcpy.sa import *

		# Set local variables
		inZoneData = Points_on_Tc
		zoneField = "OBJECTID"
		inValueRaster = SRTM_Digital_Elevation_Data_30m_tif
		outTable = os.path.join(output_loc,"X_ZonalStatsTc")


		# Check out the ArcGIS Spatial Analyst extension license
		arcpy.CheckOutExtension("Spatial")

		# Execute ZonalStatisticsAsTable
		X_zonalStats_Tc = ZonalStatisticsAsTable(inZoneData, zoneField, inValueRaster, 
										 outTable, "NODATA", "MEAN")

		featureclass1 = design_road
		featureclass2 = X_zonalStats_Tc
		field_names1 = ['Shape_Length'] # for design_road
		field_names2 = ['MEAN'] # for X_zonalStats_Tc

		# variables
		tc_length=0
		tc_mean=[]
		with arcpy.da.SearchCursor(featureclass1, field_names1) as cursor_d:
			for row in cursor_d:
				tc_length=row[0]

		with arcpy.da.SearchCursor(featureclass2, field_names2) as cursor1:
			for row in cursor1:
				tc_mean.append(row[0])

		# print total length
		print("the length of the critical path is: {}".format(tc_length))
		list_excel.append(tc_length)
		
		# slope
		slope=(max(tc_mean)-min(tc_mean))/ (tc_length)
		print('slope is: {}'.format(slope))
		list_excel.append((slope))
		
		# sheet flow calculation
		# local variables
		mannings_n= 0.011 # check
		print('mannings_n is: {}'.format(mannings_n))
		intensity_mm_hr = 1.14*3.285  # mm ; only 3.285 for without climate change
		p2_24mm= intensity_mm_hr*24  # mm for 24 hr duration
		slope_sheet= slope
		length_sheet= 30 * 3.28 # 30 meters and converting to feet
		Tc_sheetFlow = ((0.007*(mannings_n*length_sheet)**0.8)/((p2_24mm*0.0393701)**0.5 * (slope_sheet)**0.4))* 60 # in mins 
		p30_24mm = 5.6353*24 # mm for 24 hrs durations 30 year return period 

		#channel flow
		velocity_assumed= 4.0 # m/s
		Tc_channel= (tc_length-30)/(60*velocity_assumed)
		tc_total= Tc_channel+Tc_sheetFlow
		print('tc_total: {}'.format(tc_total))
		list_excel.append(tc_total)
		
		# intensity
		# """
		
		# Output of the below mentioned scripts results in 15 min rainfall data
		# +---cascade_modelling_scripts
		# |       Cascade_Aggregation.m
		# |       Cascade_DisAggregation.m
		
		# Output of the below mentioned scripts results in rainfall correction factors
		# +---gcm_scripts
		# |       GCM_RFC.m
		
		# Output of the below mentioned scripts results in design non-stationary IDF curves 
		# +---IDF_scripts
		# 		Cascasde_IDF.m
		# 		idf_curves.m
		# """
		new_intensity = 1302.4*tc_total**(-0.776) #power_Equation (t in mins) 1142.4

		print("the intensity of rainfall is: {}".format(new_intensity))
		list_excel.append(new_intensity)

		# coef of runoff
		feature_class= X_clustered_design_area_clip
		field_name= ['class','Shape_Area']
		coef_arearunoff=[] # calculate C1*A1 +C2*A2 ...
		area_runoff= [] # calculate the total area A1+A2+...
		classes_coef= coef_of_runoff_classes  # check
		
		with arcpy.da.SearchCursor(feature_class, field_name) as cursor:
		
			for row in cursor:
				coef_arearunoff.append(classes_coef[row[0]]*row[1])
				area_runoff.append(row[1])

		coef_of_runoff= sum(coef_arearunoff)/sum(area_runoff)
		print('coef_of_runoff is : {}'.format(coef_of_runoff))
		list_excel.append(coef_of_runoff)
		# discharge
		Q_dis= 0.028* coef_of_runoff * (new_intensity/10) * sum(area_runoff)* 0.0001  # area in ha now, intensity in cm/hr
		print('Discharge Q is: {}'.format(Q_dis))
		list_excel.append(Q_dis)

		# Python program for implementation 
		# of Bisection Method for solving equations 

		mannings_n= 0.011 # assumed fixed [RCC concrete surface]
		b_width= 1.5 # meters
		depth_assumed= 2.0 # meters
		side_slope = 0.0

		def func(depth_assumed):

			A_f= (b_width +side_slope * depth_assumed)*depth_assumed  # in m2
			P_peri= b_width + 2*np.sqrt(side_slope**2+1)*depth_assumed  # in meters
			R_radius= float(A_f)/P_peri  #
			Q_cal= (1/mannings_n)*A_f*(R_radius**(0.666))*drain_slope**(0.5)  # in m3/s

			return Q_dis-Q_cal

		# Prints root of func(x) 
		# with error of EPSILON 
		def bisection(a,b): 

			if (func(a) * func(b) >= 0): 
				print("You have not assumed right a and b\n") 
				return ""

			c = a 
			while (abs(b-a) >= 0.01): 

				# Find middle point 
				c = (a+b)/2

				# Check if middle point is root 
				if (func(c) == 0.0): 
					break

				# Decide the side to repeat the steps 
				if (func(c)*func(a) < 0): 
					b = c 
				else: 
					a = c 
					
			print("The value of root is : ","%.4f"%c)
			print("----------------------------------")
			return c


		# Driver code 
		# Initial values assumed 
		a =20.0
		b = 0.0
		depth = bisection(a, b) 
		list_excel.append(depth)

		import numpy as np
		# make a multi-dim array for export to excel
		if 'new_array' in globals():
			new_array= np.insert(new_array, 0,list_excel,axis=1)

		else:	
			new_array = np.array( list_excel).reshape(-1,1)

new_array= np.insert(new_array, 0,headers,axis=1)
# save to excel as csv
tm_mon = time.localtime().tm_mon
tm_day = time.localtime().tm_mday
tm_hr =  time.localtime().tm_hour
tm_min = time.localtime().tm_min
save_file_loc = os.path.join(output_loc, 'roads_csv')
np.savetxt(os.path.join(os.path.abspath(os.path.join(os.getcwd(), "../output/")),'roads_csv','roads_{}_{}_{}_{}.csv'.format(tm_mon, tm_day, tm_hr, tm_min)),new_array,delimiter=',', fmt='%s')

# calculate execution time
print(time.clock()- starttime, 'seconds')

# end