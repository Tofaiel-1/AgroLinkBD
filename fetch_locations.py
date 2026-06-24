import urllib.request, json, os

def fetch_and_generate():
    print("Fetching data from github...")
    url_div = 'https://raw.githubusercontent.com/nuhil/bangladesh-geocode/master/divisions/divisions.json'
    divisions = json.loads(urllib.request.urlopen(url_div).read().decode())[2]['data']
    
    url_dist = 'https://raw.githubusercontent.com/nuhil/bangladesh-geocode/master/districts/districts.json'
    districts = json.loads(urllib.request.urlopen(url_dist).read().decode())[2]['data']
    
    url_upa = 'https://raw.githubusercontent.com/nuhil/bangladesh-geocode/master/upazilas/upazilas.json'
    upazilas = json.loads(urllib.request.urlopen(url_upa).read().decode())[2]['data']
    
    # Process divisions
    div_map = {}
    for d in divisions:
        div_map[d['id']] = d['name']
        
    # Process districts
    dist_map = {}
    dist_by_div = {}
    for d in districts:
        dist_map[d['id']] = d['name']
        div_id = d['division_id']
        if div_id not in dist_by_div:
            dist_by_div[div_id] = []
        dist_by_div[div_id].append(d['name'])
        
    # Process upazilas
    upa_by_dist = {}
    for u in upazilas:
        dist_id = u['district_id']
        dist_name = dist_map.get(dist_id, '')
        if not dist_name: continue
        if dist_name not in upa_by_dist:
            upa_by_dist[dist_name] = []
        upa_by_dist[dist_name].append(u['name'])
        
    dart_code = '/// Auto-generated Bangladesh location data\nclass BDLocationData {\n'
    
    # Divisions
    dart_code += '  static const List<String> divisions = [\n'
    for name in sorted(div_map.values()):
        dart_code += f'    "{name}",\n'
    dart_code += '  ];\n\n'
    
    # Districts by Division
    dart_code += '  static const Map<String, List<String>> districtsByDivision = {\n'
    for div_id, dists in dist_by_div.items():
        div_name = div_map[div_id]
        dart_code += f'    "{div_name}": [\n'
        for dist in sorted(dists):
            dart_code += f'      "{dist}",\n'
        dart_code += '    ],\n'
    dart_code += '  };\n\n'
    
    # Upazilas by District
    dart_code += '  static const Map<String, List<String>> upazilasByDistrict = {\n'
    for dist_name, upas in upa_by_dist.items():
        dart_code += f'    "{dist_name}": [\n'
        for upa in sorted(upas):
            dart_code += f'      "{upa}",\n'
        dart_code += '    ],\n'
    dart_code += '  };\n'
    dart_code += '}\n'
    
    os.makedirs('lib/core/constants', exist_ok=True)
    with open('lib/core/constants/bd_location_data.dart', 'w', encoding='utf-8') as f:
        f.write(dart_code)
        
    print('Generated lib/core/constants/bd_location_data.dart successfully.')

fetch_and_generate()
