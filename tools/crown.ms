-- Crown�ĳ��������ű�
global isExportHide = true
global sceneFileName = ""	-- ������ļ���
global savePath = ""	-- �����Ŀ¼
global texturePath = ""	-- ��ͼĿ¼
global effectPath=""	-- ��ЧĿ¼
global soundPath=""	-- ��ЧĿ¼
global terrainTexturePath = ""	-- �ر���ͼĿ¼
global xmlString = stringstream""	-- ����������xml
global errString = stringstream""	-- ��������
global CrownExport		-- ����
global maxX, maxY, minX, minY	-- ����boundingbox
global exportTextureArray = #()	-- ������ͼ�б�
global triggerNameList= #()		-- trigger
global triggerCount = 0			-- trigger��

function uppercase instring = -- beginning of function definition
(
	local upper, lower, outstring -- declare variables as local
	upper="ABCDEFGHIJKLMNOPQRSTUVWXYZ" -- set variables to literals
	lower="abcdefghijklmnopqrstuvwxyz"
	-- create an unique copy of the string referenced by instring, and store
	-- reference to unique copy in outstring
	outstring=copy instring
	-- increment from 1 to number of character in string
	for i=1 to outstring.count do
		-- see if the single character at index i in outstring is present in string lower
		-- If so, j equals position in string lower. If not, j equals undefined
	(
		j=findString lower outstring[i]
		-- if character was found in lower, replace with corresponding character in upper
		if (j != undefined) do outstring[i]=upper[j]
	)
	return outstring -- value of outstring will be returned as function result

) -- end of fn uppercase

function lowercase instring = -- beginning of function definition
(
	local upper, lower, outstring -- declare variables as local
	upper="ABCDEFGHIJKLMNOPQRSTUVWXYZ" -- set variables to literals
	lower="abcdefghijklmnopqrstuvwxyz"
	-- create an unique copy of the string referenced by instring, and store
	-- reference to unique copy in outstring
	outstring = copy instring
	-- increment from 1 to number of character in string
	for i=1 to outstring.count do
	(
		j = findString upper outstring[i]
		if (j != undefined) do outstring[i]=lower[j]
	)
	return outstring

) -- end of fn lowercase

function updateBound mesh =
(
--	format "debug=% %\n" mesh.max mesh.min
	if maxX < mesh.max.x do maxX = mesh.max.x
	if maxY < mesh.max.y do maxY = mesh.max.y
	if minX > mesh.min.x do minX = mesh.min.x
	if minY > mesh.min.y do minY = mesh.min.y
)

-- ��������ɫ�ļ�
function VertexColorExport edmesh =
(
	format "����%�Ķ���ɫ\n" edmesh.name
	isBinary = true
	-- ����ɫ�ļ���
	meshFileName = savePath  + edmesh.name + ".3dc"
--	defaultVCFaces edmesh
-- 	buildVCFaces edmesh false
	cpvNum = getNumCPVVerts edmesh
	vertexNum = getNumVerts edmesh
	faceNum = getNumFaces edmesh
	format "vertexNum=% cpvNum=% faceNum=%\n" vertexNum cpvNum faceNum
	
	-- ��鶥��ɫ��������������3��
	if (faceNum*3) != cpvNum do
	(
		format "ģ��% �Ķ���ɫ��������*3����\n" edmesh.name
		format "ģ��% �Ķ���ɫ��������*3����\n" edmesh.name to: errString 
		return false
	)
	
	if isBinary then
		clrFile = fopen (lowercase meshFileName) "wb"
	else
		clrFile = openFile (lowercase meshFileName) mode:"wt"
	
	result = true

	if clrFile != undefined then
	(
		try
		(
			if false then
			(	-- version 1
				if isBinary then
				(
					WriteLong clrFile 1 unsigned		-- �汾��
					WriteLong clrFile cpvNum unsigned	-- ����ɫ��
				)
				else
				(
					format "cpvNum %\n" cpvNum --to:clrFile
				)
				
				for i=1 to faceNum do
				(
					for j=1 to 3 do
					(
						cpvIndex = (i-1)*3 + j
						color = getVertColor edmesh cpvIndex
						if isBinary then
						(
							WriteByte clrFile color.red unsigned
							WriteByte clrFile color.green unsigned
							WriteByte clrFile color.blue unsigned
						)
						else
						(
							format "% % %\n" \
							color.red color.green color.blue --to:clrFile
						)
					)
				)
			)
			else
			(	-- version 2
				WriteLong clrFile 2 unsigned		-- �汾��
				
				WriteLong clrFile cpvNum unsigned	-- ����ɫ��
				colorArray = #()
				-- д��ɫ����
				for i=1 to faceNum do
				(
					--xx = getVCFace edmesh i
					--format "% % " i xx
					
					--yy = getFace edmesh i
					--format "%" yy
					
					for j=1 to 3 do
					(
						cpvIndex = (i-1)*3 + j
						
						color = getVertColor edmesh cpvIndex
						-- ��ɫֵȡģ(ѹ����ɫ��)
						color.r = floor (color.r/5) * 5
						color.g = floor (color.g/5) * 5
						color.b = floor (color.b/5) * 5
											
						clrIndex = findItem colorArray color
						if clrIndex > 0 then
							WriteShort clrFile (clrIndex-1) unsigned
						else
						(
							append colorArray color
							clrIndex = (colorArray.count-1)
							WriteShort clrFile (colorArray.count-1) unsigned							
						)
						
						--format " % %" clrIndex color
					)
					
					--format "\n"
				)
				
				WriteLong clrFile colorArray.count unsigned		-- ��ɫ��
				-- д��ɫ�б�
				for i=1 to colorArray.count do
				(
					WriteByte clrFile colorArray[i].r unsigned
					WriteByte clrFile colorArray[i].g unsigned
					WriteByte clrFile colorArray[i].b unsigned
				)
			)
		)
		catch
		(
			format "% ��������ɫ�ļ�����\n" edmesh.name
			format "% ��������ɫ�ļ�����\n" edmesh.name to: errString 
			result = false
		)
		if isBinary then
			fclose clrFile
		else
			close clrFile
	)
	
	return result
)

-- ����Mesh����ͼ
function TextureExport edmesh =
(
	if( (classof edmesh.material) as string != "Standardmaterial" ) then
	(
		format "% �Ĳ��ʲ���Standardmateria\n" edmesh.name
		return undefined
	)
	
	if( (classof edmesh.material.diffuseMap) as string != "Bitmaptexture" ) then
	(
		format "% �Ĳ��ʵ�diffusemap����Bitmaptexture\n" edmesh.name
		return undefined
	)
	-- ���õ�����ͼ��Ŀ¼
	desPath = ""
	if texturePath.count > 0 then
	(
		desPath = savePath
		desPath = substring desPath 1 (desPath.count-1)
		desPath = getFilenamePath desPath
		desPath = desPath + texturePath + "\\"
		--format "desPath=%\n" desPath
	)
	else
		desPath = savePath
	
	-- ������ͼ
	srcAllFileName = edmesh.material.diffuseMap.filename
	srcFileName = getFilenameFile srcAllFileName + getFilenameType srcAllFileName
	
	--desFileName = getFilenameFile srcAllFileName + getFilenameType srcAllFileName 
	desFileName = getFilenameFile srcAllFileName + ".dds"	-- ��ͼ��Ϊ
	desAllFileName = desPath + desFileName
	desAllFileName = lowercase desAllFileName		-- Сд
	-- �����ͼ������
	justFileName = getFilenameFile desFileName
	justExtName = getFilenameType desFileName
	if(justFileName.count > 8) then
	(
		format "��ͼ % ������8���ַ�\n" justFileName
		format "��ͼ % ������8���ַ�\n" justFileName to:errString
		justFileName = substring justFileName 1 8
		desAllFileName = desPath + justFileName + justExtName
		format "��ͼ����Ϊ%\n" desAllFileName 
		--return undefined
	)

	if(justExtName != ".png" and justExtName != ".jpg" and justExtName != ".tga" and justExtName != ".dds") then
	(
		format "��ͼ % ��Ϊtga,png,dds��jpg\n" srcAllFileName
		format "��ͼ % ��Ϊtga,png,dds��jpg\n" srcAllFileName to: errString
		return undefined
	)
	
	format "����ģ�� % ����ͼ %\n" edmesh.name desAllFileName 
		
	-- ���Դ��ͼ�Ƿ����
	isExist = false
	if( doesFileExist srcAllFileName ) then isExist = true

	testFileName = sysInfo.currentdir + "\\" + srcFileName;
	if( doesFileExist testFileName ) then isExist = true

	testFileName = maxFilePath + srcFileName;
	if( doesFileExist testFileName ) then isExist = true
 
	if(isExist == false) then
	(
		format "��ͼ % ������\n" srcAllFileName
		format "��ͼ % ������\n" srcAllFileName to: errString
		return undefined
	)
	
	-- �����ͼ�Ƿ��Ѿ�������
	if (findItem exportTextureArray desAllFileName) != 0 then
	(
		format "��ͼ % �Ѿ�����\n" desAllFileName
		return desAllFileName
	)
		
	-- ������ͼ
	try(
		srcBmp = edmesh.material.diffuseMap.bitmap
		--format "%\n" srcBmp
		desBmp = bitmap srcBmp.width srcBmp.height filename:desAllFileName 

		copy srcBmp desBmp
		save desBmp
		close desBmp
	)
	catch
	(
		format "%������ͼʧ��\n" edmesh.name
		format "%������ͼʧ��\n" edmesh.name to:errString
		return undefined
	)
	-- ��¼��������ͼ
	append exportTextureArray desAllFileName
	
	format "������ͼ % ����\n" desAllFileName	
	return desAllFileName
)
-- ��������Mesh
function MeshExport edmesh =
(
	-- ������Mesh����ͼ
	texOk = TextureExport edmesh
	if(texOk != undefined) then
	(	
		-- ����λ��,��ת
		oldPosition = edmesh.position
		edmesh.position = [0,0,0]
		oldRotation = edmesh.rotation
		edmesh.rotation.x = 0
		edmesh.rotation.y = 0
		edmesh.rotation.z = 0
		edmesh.rotation.w = 1
		
		-- ��������
		meshFileName = savePath  + edmesh.name + ".3ds"
		-- ������ѡ������
		format "����ģ�� %\n" meshFileName 
		exportFile (lowercase meshFileName) #noPrompt selectedOnly:true	
		
		-- ��ԭλ��,��ת
		edmesh.rotation = oldRotation
		edmesh.position = oldPosition
		
		-- �������Ƿ�͸��
		isBlended = false
		if edmesh.material.opacityMap != undefined do
			isBlended  = true
		-- �Ƿ���˫����Ⱦ
		isTwoSided = false
		if edmesh.material.twoSided do
			isTwoSided = true
		-- layer����
		layer = 0
		value = getUserProp edmesh "layer"
		if value != undefined and (isKindOf value number) then
			layer = value 
		-- shadow����(�Ƿ������Ӱ)
		shadow = false
		value = getUserProp edmesh "shadow"
		if value != undefined then
			shadow = value
		-- �ܹ�����(�Ƿ���ܳ����ƹ���)
		light = true
		value = getUserProp edmesh "light"
		if value != undefine and value==false then
			light = false
		-- ����
		scale = 1.0
		value = getUserProp edmesh "scale"
		if value != undefine then
			scale = value
		-- zwrite����
		zWrite = undefined
		value = getUserProp edmesh "zwrite"
		if value != undefined then
			zWrite = value
		-- ztest����
		zTest = undefined
		value = getUserProp edmesh "ztest"
		if value != undefined then
			zTest = value
		-----------------------------------------------
		-- ��������	
		hasAnimation = false
		-- λ�ƶ���
		ani_path = undefined
		value = getUserProp edmesh "ani_path"
		if value != undefined then
		(
			ani_path = value
			hasAnimation = true
		)
		-- ��ת����
		ani_rot = undefined
		value = getUserProp edmesh "ani_rot"
		if value != undefined then
		(
			ani_rot = value
			hasAnimation = true
		)
		-- ���Ŷ���
		ani_scl = undefined
		value = getUserProp edmesh "ani_scl"
		if value != undefined then
		(
			ani_scl = value
			hasAnimation = true
		)
		-- ��ɫ����
		ani_clr = undefined
		value = getUserProp edmesh "ani_clr"
		if value != undefined then
		(
			ani_clr = value
			hasAnimation = true
		)
		-- UV����
		ani_uv = undefined
		value = getUserProp edmesh "ani_uv"
		if value != undefined then
		(
			ani_uv = value;
			hasAnimation = true
		)
			
		-- �ر���Ⱦ����
		terrainTex = ""
		value = getUserProp edmesh "terraintex"		-- �����ͼ
		if value != undefined then
			terrainTex = value
		terrainTex1 = ""
		value = getUserProp edmesh "terraintex1"	-- �ر�����1
		if value != undefined then
			terrainTex1 = value
		terrainTex2 = ""
		value = getUserProp edmesh "terraintex2"	-- �ر�����2
		if value != undefined then
			terrainTex2 = value
		terrainTex3 = ""
		value = getUserProp edmesh "terraintex3"	-- �ر�����3
		if value != undefined then
			terrainTex3 = value
		terrainTex4 = ""
		value = getUserProp edmesh "terraintex4"	-- �ر�����4
		if value != undefined then
			terrainTex4 = value
		uvScale = 1
		value = getUserProp edmesh "uvscale"		-- UV����
		if value != undefined then
			uvScale = value
		
		
		-- ��������ɫ�ļ�
		hasVertexColor = false
		cpvNum = getNumCPVVerts edmesh
		if cpvNum != 0 do
		(
			hasVertexColor = VertexColorExport edmesh
		)
			
		-- ����xml
		format "<mesh name=\"%\" vertexColor=\"%\">\n" \
			(lowercase edmesh.name) hasVertexColor to:xmlString
		
		-- ��xml����Ըö����λ�ƺ���ת(SWAP YZ,����ռ�),
		format "\t<pos x=\"%\" y=\"%\" z=\"%\"></pos>\n" \
			edmesh.position.x edmesh.position.z edmesh.position.y to:xmlString
		format "\t<rot rx=\"%\" ry=\"%\" rz=\"%\" rw=\"%\"></rot>\n" \
			-edmesh.rotation.x -edmesh.rotation.z -edmesh.rotation.y edmesh.rotation.w\
			to:xmlString
		format "\t<scale s=\"%\"></scale>\n" \
			scale \
			to:xmlString
		-- ����
		format "\t<mat blend=\"%\" twoSide=\"%\" layer=\"%\" shadow=\"%\" light=\"%\"" \
			isBlended isTwoSided layer shadow light to:xmlString
		if zWrite != undefined then
			format " zwrite=\"%\"" zWrite to:xmlString
		if zTest != undefined then
			format " ztest=\"%\"" zTest to:xmlString

		format "></mat>\n" to:xmlString
		-- ��������
		if hasAnimation then
		(
			format "\t<animation>\n" to:xmlString
			if ani_path != undefined then
			(
				format "\t\t%\n" ani_path to:xmlString
			)			
			-- ��ת����
			if ani_rot != undefined then
			(
				format "\t\t%\n" ani_rot to:xmlString
			)
			-- ���Ŷ���
			if ani_scl != undefined then
			(
				format "\t\t%\n" ani_scl to:xmlString
			)
			-- ��ɫ����
			if ani_clr != undefined then
			(
				format "\t\t%\n" ani_clr to:xmlString
			)
			-- UV����
			if ani_uv != undefined then
			(
				format "\t\t%\n" ani_uv to:xmlString
			)
			format "\t</animation>\n" to:xmlString
		)
		-- �ر�����
		if terrainTex.count > 0 then
		(
			format "\t<terraintex tex=\"%\" tex1=\"%\" tex2=\"%\" tex3=\"%\" tex4=\"%\" uvscale=\"%\"/>\n" \
				terrainTex terrainTex1 terrainTex2 terrainTex3 terrainTex4 uvScale \
				to:xmlString
		)
		
		format "</mesh>\n" to:xmlString
		
		updateBound edmesh			-- �������緶Χ		
	)else(
		format "ģ��% ����ͼ���ⲻ����\n" edmesh.name
		format "ģ��% ����ͼ���ⲻ����\n" edmesh.name to: errString 
	)
)

-- ������պ�
function SkyBoxExport  edmesh =
(
	format "������պ� %\n" edmesh.name
	
	-- ��պе�λ�ú���ת��Ϊ0
	edmesh.position = [0,0,0]
	edmesh.rotation.x = 0
	edmesh.rotation.y = 0
	edmesh.rotation.z = 0
	edmesh.rotation.w = 1
	-- ������պ���ͼ
	texOk = TextureExport edmesh
	if(texOk != undefined) then
	(
		-- ��������
		meshFileName = savePath  + edmesh.name + ".3ds"
		-- ������ѡ������
		format "����ģ�� %\n" meshFileName 
		exportFile meshFileName #noPrompt selectedOnly:true	
			
		-- ��xml����Ըö����λ�ƺ���ת(SWAP YZ,����ռ�),
		format "<skybox name=\"%\"></skybox>\n" edmesh.name to:xmlString
	)else(
		format "��պ�% ����ͼ���ⲻ����\n" edmesh.name
		format "��պ�% ����ͼ���ⲻ����\n" edmesh.name to: errString 

	)
)
-- ��������Mesh
function TerrainExport edmesh =
(
	format "�������� %\n" edmesh.name
	
	-- ���ε�λ�ú���ת��Ϊ0
	edmesh.position = [0,0,0]
	edmesh.rotation.x = 0
	edmesh.rotation.y = 0
	edmesh.rotation.z = 0
	edmesh.rotation.w = 1
		
	-- ��������
	meshFileName = savePath  + edmesh.name + ".3ds"
	-- ������ѡ������
	format "����ģ�� %\n" meshFileName 
	exportFile meshFileName #noPrompt selectedOnly:true	
		
	-- ��xml����Ըö����λ�ƺ���ת(SWAP YZ,����ռ�),
	format "<terrain name=\"%\"></terrain>\n" edmesh.name to:xmlString
)
-- ����������
function LightExport edmesh =
(
	format "������ %\n" edmesh.name
	texName = TextureExport edmesh
	if(texName != undefined) then
	(
		texFileName = filenameFromPath texName 
		lightPos = edmesh.position
		-- ��õƵĴ�С
		value = getUserProp edmesh "size"
		lightSize = 100
		--format "%\n" (isKindOf strSize integer)
		if value != undefined and (isKindOf value integer) then
			lightSize = value 
		-- ��õƵ���ת
		lightRot = (asin(edmesh.rotation.z)*2) + 90
		-- ��õƵ���ɫ
		clrR = 255
		clrG = 255
		clrB = 255
		value = getUserProp edmesh "clrR"
		if value != undefined and (isKindOf value integer) then
			clrR = value
		value = getUserProp edmesh "clrG"
		if value != undefined and (isKindOf value integer) then
			clrG = value
		value = getUserProp edmesh "clrB"
		if value != undefined and (isKindOf value integer) then
			clrB = value
		-- ��ù���ǿ��
		bright = 1.0
		value = getUserProp edmesh "bright"
		if value != undefined and (isKindOf value number) then
			bright = value

		format "<light name=\"%\" tex=\"%\" size=\"%\" bright=\"%\" x=\"%\" z=\"%\" rot=\"%\" r=\"%\" g=\"%\" b=\"%\"></light>\n" \
			(lowercase edmesh.name) (lowercase texFileName) lightSize bright \
			edmesh.position.x edmesh.position.y  \
			lightRot \
			clrR clrG clrB \
			to:xmlString
	)
	else
	(
		format "ģ��% ����ͼ���ⲻ����\n" edmesh.name
		format "ģ��% ����ͼ���ⲻ����\n" edmesh.name to: errString 

	)
)
-- ������Ч
function EffectExport edmesh =
(
	effectName = undefined
	value = getUserProp edmesh "effect"
	if value != undefined then
		effectName = value
	
	if effectName == undefined then
	(
		format "��Ч%û�ж���\n" edmesh.name
		return undefined
	)
	
	format "������Ч % %\n" edmesh.name effectName 
	
	format "<effect name=\"%\" file=\"%\">\n" edmesh.name effectName to:xmlString

	format "\t<pos x=\"%\" y=\"%\" z=\"%\"></pos>\n" \
		edmesh.position.x edmesh.position.z edmesh.position.y to:xmlString
	format "\t<rot rx=\"%\" ry=\"%\" rz=\"%\" rw=\"%\"></rot>\n" \
		-edmesh.rotation.x -edmesh.rotation.z -edmesh.rotation.y edmesh.rotation.w\
		to:xmlString
		
	format "</effect>\n" to:xmlString

)
-- ������Ч
function SoundExport edmesh =
(
	soundName = undefined
	value = getUserProp edmesh "sound"
	if value != undefined then
		soundName = value
	
	if soundName == undefined then
	(
		format "��Ч%û�ж���\n" edmesh.name
		return undefined
	)
	
	soundRange = 1000
	value = getUserProp edmesh "range"
	if value != undefined then
		soundRange = value
	
	format "������Ч % %\n" edmesh.name soundName 
	
	format "<sound name=\"%\" file=\"%\" range=\"%\">\n" edmesh.name soundName soundRange to:xmlString

	format "\t<pos x=\"%\" y=\"%\" z=\"%\"></pos>\n" \
		edmesh.position.x edmesh.position.z edmesh.position.y to:xmlString
	format "</sound>\n" to:xmlString

)
-- ����ˮ
function WaterExport edmesh =
(
	-- ������Mesh����ͼ
	texOk = TextureExport edmesh
	if(texOk != undefined) then
	(
		-- ����λ��,��ת
		oldPosition = edmesh.position
		edmesh.position = [0,0,0]
		oldRotation = edmesh.rotation
		edmesh.rotation.x = 0
		edmesh.rotation.y = 0
		edmesh.rotation.z = 0
		edmesh.rotation.w = 1
		
		-- ��������
		meshFileName = savePath  + edmesh.name + ".3ds"
		-- ������ѡ������
		format "����ģ�� %\n" meshFileName 
		exportFile (lowercase meshFileName) #noPrompt selectedOnly:true	
		
		-- ��ԭλ��,��ת
		edmesh.rotation = oldRotation
		edmesh.position = oldPosition
		-- ˮ����
		alpha = 1.0
		value = getUserProp edmesh "alpha"
		if value != undefined then
			alpha = value
		uspeed = 0
		value = getUserProp edmesh "uspeed"
		if value != undefined then
			uspeed = value
				
		-- ����xml
		format "<water name=\"%\">\n" (lowercase edmesh.name) to:xmlString
		
		-- ��xml����Ըö����λ�ƺ���ת(SWAP YZ,����ռ�),
		format "\t<pos x=\"%\" y=\"%\" z=\"%\"></pos>\n" \
			edmesh.position.x edmesh.position.z edmesh.position.y to:xmlString
		format "\t<rot rx=\"%\" ry=\"%\" rz=\"%\" rw=\"%\"></rot>\n" \
			-edmesh.rotation.x -edmesh.rotation.z -edmesh.rotation.y edmesh.rotation.w\
			to:xmlString

		format "\t<property alpha=\"%\" uspeed=\"%\"></property>\n" alpha uspeed to:xmlString
		format "</water>\n" to:xmlString
	)
	else
	(
		format "ˮ% ����ͼ���ⲻ����\n" edmesh.name
		format "ˮ% ����ͼ���ⲻ����\n" edmesh.name to: errString 

	)
)
--������������
function EnvExport edmesh =
(
	format "������������\n"
	-- �ƹⱳ��ɫ
	LightBackGroundR = 100
	LightBackGroundG = 100
	LightBackGroundB = 100

	value = getUserProp edmesh "LightBackGroundR"
	if value != undefined then LightBackGroundR = value
	value = getUserProp edmesh "LightBackGroundG"
	if value != undefined then LightBackGroundG = value
	value = getUserProp edmesh "LightBackGroundB"
	if value != undefined then LightBackGroundB = value
	
	-- ��
	fogColorR = 0
	fogColorG = 0
	fogColorB = 0
	fogNear = 10000
	fogFar = 20000
	fogAlpha = 1
	
	value = getUserProp edmesh "fogR"
	if value != undefined then fogColorR = value
	value = getUserProp edmesh "fogG"
	if value != undefined then fogColorG = value
	value = getUserProp edmesh "fogB"
	if value != undefined then fogColorB = value
	value = getUserProp edmesh "fogNear"
	if value != undefined then fogNear = value
	value = getUserProp edmesh "fogFar"
	if value != undefined then fogFar = value
	value = getUserProp edmesh "fogAlpha"
	if value != undefined then fogAlpha = value

		
	format "<env>\n" to:xmlString
	
	format "\t<LightBackGround r=\"%\" g=\"%\" b=\"%\"></LightBackGround>\n" \
		LightBackGroundR LightBackGroundG LightBackGroundB to:xmlString
	format "\t<Fog r=\"%\" g=\"%\" b=\"%\" near=\"%\" far=\"%\" alpha=\"%\"></Fog>\n" \
		fogColorR fogColorG fogColorB fogNear fogFar fogAlpha to:xmlString

	
	format "</env>\n" to:xmlString
)
-- ����������ײ��Χ
global hasWorld = false
function WallExport line =
(
	pointNum = numKnots line 
	format "����������ײ��Χ % pointNum=%\n" line.name pointNum -- ����
	
	format "�м����߶�%\n" (numSplines line)
	if (numSplines line)>1 then
	(
		format "%�г���һ���߶�\n" line.name 
		format "%�г���һ���߶�\n" line.name to: errString
	)
	--format "�Ƿ�պ�%\n" (isClosed line 1)
	if (isClosed line 1) == false then
	(
		format "%���պ�\n" line.name 
		format "%���պ�\n" line.name to: errString
	)

	type = 1		-- 1 world, 2 wall, 3 hole, 4 monster
	tag = ""
	if lowercase line.name == "world" then 
	(
		type = 1
		tag = "world"
		hasWorld = true
	)
	else if lowercase (substring line.name 1 7) == "monster" then
	(
		type = 4
		tag = "monster"
	)
	else if lowercase (substring line.name 1 4) == "wall" then
	(
		type = 2
		tag = "wall"
	)
	else
	(
		type = 3
		tag = "hole"
	)
	
	if type == 4 then
	(
		format "<% name=\"%\">\n" tag line.name to:xmlString
	)
	else
	(
		format "<%>\n" tag to:xmlString
	)
	
	-- �����߶��еĵ�
	lastPointPos = undefined
	for pointI=1 to pointNum do
	(
		pro = (pointI-1) as Float
		pro = pro / pointNum 
		points = pathInterp line 1 pro
		-- ���������㲻���Ծ���̫��
		if lastPointPos != undefined then
		(
			dis = distance lastPointPos points
			if dis < 1 then
			(
				format "%�ĵ�%������һ����̫��\n" line.name pointI
				format "%�ĵ�%������һ����̫��\n" line.name pointI to: errString
			)
		)
		else
			lastPointPos = points 
		
		format "% % %\n" pointI pro points 
		format "\t<point x=\"%\" z=\"%\"></point>\n" \
			points[1] points[2] \
			to:xmlString			
	)
	
	format "</%>\n" tag to:xmlString
	
)
-- ����dummy
function DummyExport dummy =
(
	-- ���û���ظ�������
	isNameExist = false
	for nameI=1 to triggerNameList.count do
	(
		if triggerNameList[nameI] == (lowercase dummy.name) then
		(
			format "�����ظ�%\n" dummy.name
			isNameExist = true
		)
	)
	if isNameExist == true do
	(
		format "dummy���ظ�������%\n" dummy.name to: errString
		return undefined
	)
	-- ����Ƿ�hide
	if dummy.isHidden and isExportHide == false do
	(
		format "% ����\n" dummy.name
		return undefined
	)
		
	append triggerNameList (lowercase dummy.name)
	
	format "����dummy %\n" dummy.name
	
	dummyRot = (asin(dummy.rotation.z)*2) + 90
	
	triggerCount += 1
	format "<trigger name=\"%\" x=\"%\" y=\"%\" z=\"%\" rot=\"%\"></trigger>\n" \
		triggerCount dummy.position.x dummy.position.z dummy.position.y -(dummyRot)\
		to:xmlString
		
	
)
-- ������������
function SceneExport = 
(	
	clearSelection()
	setCommandPanelTaskMode #create	-- ѡ�񴴽������Ա������ˢ��
	-- ��ʼ�������Сֵ
	maxX = -9999999
	maxY = -9999999
	minX = 9999999
	minY = 9999999
	
	format "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n" to:xmlString
	format "<scene xmlns=\"\">\n" to:xmlString
	format "<texturepath path=\"%\"/>\n" texturePath to:xmlString
	format "<terraintexturepath path=\"%\"/>\n" terrainTexturePath to:xmlString
	format "<effectpath path=\"%\"/>\n" effectPath to:xmlString
	format "<soundpath path=\"%\"/>\n" soundPath to:xmlString
	
	format "��ǰĿ¼ %\\\n" sysInfo.currentdir
	format "��ǰmax�ļ�Ŀ¼%\n" maxFilePath
	format "����Ŀ¼ %\n" savePath 
	-- �Գ���������Editable_mesh
	meshNameList = #()
	exportTextureArray = #()
	triggerNameList = #()
	
	triggerCount = 0		-- trigger����0
	geocount = geometry.count
	geoi = 0
	for meshi in geometry do
	(	
		geoi += 1
		CrownExport.progExport.value = 90 * geoi / geocount	-- ������
		select meshi 		-- ѡ�и�����
		-- �ų���Editable_mesh
		if (((classof meshi ) as string) != "Editable_mesh") do
		(
			if (((classof meshi ) as string) == "Box") then
			(	-- Box������Ϊdummy
				DummyExport meshi
			)
			else
			(
				format "geometry % is not Editable_mesh\n" meshi
				format "geometry % is not Editable_mesh\n" meshi to: errString
			)
			continue
		)
		-- ���û���ظ�������
		isNameExist = false
		for nameI=1 to meshNameList.count do
		(
			if meshNameList[nameI] == (lowercase meshi.name) then
			(
				--format "�����ظ�%\n" meshi.name
				format "��������%\n" meshi.name
				isNameExist = true
			)
		)
		if isNameExist == true do
		(
			format "���ظ�������%\n" meshi.name to: errString
			--continue
		)
		-- ���û�ж����mesh
		if (getNumVerts meshi) == 0 do
		(
			format "%�Ķ�����Ϊ0\n" meshi.name to: errString
			continue
		)
		-- ���û��face��mesh
		if (meshi.numfaces) == 0 do
		(
			format "%������Ϊ0\n" meshi.name to: errString
			continue
		)
		-- ���mesh�Ķ���������������
		if (meshi.numfaces > 65536) or (meshi.numverts > 65536) do
		(
			format "%�������򶥵���>65536\n" meshi.name to: errString
			continue
		)
		
		-- ����Ƿ�hide
		if meshi.isHidden and isExportHide == false do
		(
			format "% ����\n" meshi.name
			continue
		)
			
		append meshNameList (lowercase meshi.name)
		--format "����%\n" meshi.name
		
		-- ��������mesh
		if lowercase meshi.name == "terrain" do
		(
			TerrainExport meshi 
			continue
		)
		-- ����������
		if lowercase (substring meshi.name 1 5) == "light" do
		(
			LightExport meshi
			continue
		)
		-- ������Ч
		if lowercase (substring meshi.name 1 6) == "effect" do
		(
			EffectExport meshi
			continue
		)
		-- ������Ч
		if lowercase (substring meshi.name 1 5) == "sound" do
		(
			SoundExport meshi
			continue
		)
		-- ����ˮ
		if lowercase (substring meshi.name 1 5) == "water" do
		(
			WaterExport meshi
			continue
		)
		-- ������������
		if (lowercase meshi.name) == "environment" do
		(
			EnvExport meshi
			continue
		)
		-- ������պ�
		if (lowercase meshi.name) == "skybox" do
		(
			SkyBoxExport meshi 
			continue
		)
		
		-- ������ͨMesh
		format "������%��ģ��\n" geoi
		d = geoi - (geoi/100)*100;
		if(d == 0) do
		(
			gc true true
			format "gc\n"
		)
		MeshExport meshi 
	)
	-- �Գ���������shape
	shapeNameList = #()
	shapecount = shapes.count
	shapeIndex = 0
	for shapei in shapes do
	(
		shapeIndex += 1
		CrownExport.progExport.value =  90 + (10 * shapeIndex / shapecount)	-- ������
		select shapei 	-- ѡ�и�����
		
		-- ���û���ظ�������
		isNameExist = false
		for nameI=1 to shapeNameList.count do
		(
			if shapeNameList[nameI] == (lowercase shapei.name) then
			(
				format "�����ظ�%\n" shapei.name
				isNameExist = true
			)
		)
		if isNameExist == true do
		(
			format "���ظ�������%\n" shapei.name to: errString
			continue
		)
		-- ����Ƿ�hide
		if shapei.isHidden and isExportHide == false do
		(
			format "% ����\n" shapei.name
			continue
		)

		append shapeNameList (lowercase shapei.name)

		isShapeUsed = false
		format "% %\n" (isKindOf shapei shape) shapei.name
		-- �ߵĴ���
		if ( isKindOf shapei shape ) do
		(	
			isShapeUsed = true
			WallExport shapei
		)
		-- ������,�Ƿ��shape�б�ʹ��
		if isShapeUsed == false do
		(
			format "%���ǵ�������\n" shapei.name
			format "%���ǵ�������\n" shapei.name to: errString
		)
	)
	if hasWorld == false do
	(
		format "û����Ϊ\"world\"��Shape\n"
		format "û����Ϊ\"world\"��Shape\n" to: errString
	)
	
	clearSelection()
	format "<scenebound minX=\"%\" maxX=\"%\" minY=\"%\" maxY=\"%\"/>\n" \
		minX maxX minY maxY to:xmlString
	format "</scene>\n" to:xmlString
	
	format "��������\n"
)
--
function CheckDirectory srcPath= 
(
	--format "srcPath=%\n" srcPath
	desPath = ""
	if srcPath.count == 0 then
		return undefined
		
	desPath = savePath
	desPath = substring desPath 1 (desPath.count-1)
	desPath = getFilenamePath desPath
	desPath = desPath + srcPath+ "\\"
	--format "desPath=%\n" desPath
	
	exist = if (doesFileExist desPath) and (getfileattribute desPath #directory) then true else false
	if not exist then
	(
		val = makeDir desPath
		if val then
			format "����Ŀ¼%\n" desPath
		else
			format "����Ŀ¼%ʧ��\n" desPath
	)	
	
)
-- ����
rollout CrownExport "Crown������������" width:200 height:270
(
	button btnExport "��������" width:65 height:20
	checkbox exportHide "Checkbox" pos:[30,32] width:16 height:16 checked:true
	label lbl1 "������������" pos:[45,32] width:112 height:16
	label lbl2 "�����ļ���" pos:[10,50] width:152 height:16
	edittext fileNameEditor "" pos:[2,70] width:190 height:16
	label lbl3 "��ͼ��Ŀ¼��" pos:[10,90]
	edittext textureDirectoryEditor pos:[2,110] width:190 text:""
	label lbl4 "�ر���ͼ��Ŀ¼��" pos:[10,130]
	edittext terrainTextureDicectoryEditor pos:[2,150] width:190 text:"terrain"
	label lbl5 "��Ч��Ŀ¼��" pos:[10,170]
	edittext effectDirectoryEditor pos:[2,190] width:190 text:"effect"
	label lbl6 "��Ч��Ŀ¼��" pos:[10, 210]
	edittext soundDirectoryEditor pos:[2, 230] width:190 text:"sound"

	
	progressbar progExport color:blue visible:false
	--button test "test" width:65
	
	on test pressed do
	(
		if $ != undefined then
		(
			
		)
	)
	
	on btnExport pressed do
	(	
		if heapSize < 10000000 then
			heapSize = 10000000
				
		isExportHide = exportHide.checked		
		-- ����Ŀ¼�ļ�
		if (CrownExport.fileNameEditor.text.count > 0) then
		(
			sceneFileName = CrownExport.fileNameEditor.text
		)
		else
		(
			sceneFileName = "map.xml"		
		)
		-- ��ͼĿ¼&�ر���ͼ��Ŀ¼&��Ч��Ŀ¼
		texturePath = CrownExport.textureDirectoryEditor.text
		terrainTexturePath = CrownExport.terrainTextureDicectoryEditor.text
		effectPath = CrownExport.effectDirectoryEditor.text
		soundPath = CrownExport.soundDirectoryEditor.text
					
		sceneFileName = getsavefilename caption:"���泡��" \
			filename:sceneFileName \
			types:"Crown SceneFile (*.xml)|*.xml|All Files (*.*)|*.*|"
		--sceneFileName = "C:\JerryO\3D\scene\map.xml"
		if sceneFileName != undefined then
		(	
			CrownExport.fileNameEditor.text = sceneFileName
			progExport.visible = true;
			
			format "�����ļ� %\n" sceneFileName 			
			scenefile = createfile sceneFileName		-- �������������ļ�
			try
			(
				if (scenefile != undefined) then
				(
					xmlString = stringstream""
					
					savePath = getFilenamePath sceneFileName 
					
					-- ���Ŀ¼�Ƿ����
					CheckDirectory texturePath
					CheckDirectory terrainTexturePath
					CheckDirectory effectPath
					CheckDirectory soundPath
					
					SceneExport()
					
					format "%" (xmlString as string) to:scenefile 
					-- ������
					if ((errString as string).count > 0)  then
					(
						format "������\n"
						format "%" (errString as string)
						messageBox (errString as string) title:"����!"
					)else(
					
					)
										
					errString  = stringstream""
				)
				else
				(
					messagebox "���������ļ�ʧ��"
				)
			)
			catch
			(
				exceptionString = stringstream""
				format "����ʱ��������!\n*** % ***\n" (getCurrentException()) to:exceptionString
				format "�쳣 %!\n" (exceptionString as string)
				messageBox (exceptionString as string) title:"��������"
			)
			format "�رճ����ļ�\n"
			close scenefile
						
			progExport.visible = false
			
			-- �г�������ͼ
			format "������ͼ:\n"
			for i=1 to exportTextureArray.count do
			(
				format "%\n" exportTextureArray[i]
			)
			-- �г�������trigger
			format "����Trigger:\n"
			for i=1 to triggerNameList.count do
			(
				format "%\n" triggerNameList[i]
			)

			
			-- ת������tagΪblt
			--thisMaxScriptDir = getSourceFileName()
			--thisMaxScriptDir = getFilenamePath thisMaxScriptDir 
			--commandStr = thisMaxScriptDir + "ConvertTgaToBlt.exe " + (getFilenamePath sceneFileName)
			--format "DOS:%\n" commandStr 			
			--DOSCommand commandStr 
		)
		else
		(
			sceneFileName = ""	
		)
	)
)

-- �����Ի���
if CrownExportFloater != undefined do
(
	closerolloutfloater CrownExportFloater 
)
CrownExportFloater = newRolloutFloater "�������� 2.5.23" 210 300 \
	(mouse.screenpos[1]-85) (mouse.screenpos[2]-60) -- ����һ��Rollout
addRollout CrownExport CrownExportFloater 