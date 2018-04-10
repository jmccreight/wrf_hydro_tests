from pprint import pprint
import sys
sys.path.insert(0, '/Users/jamesmcc/WRF_Hydro/wrf_hydro_tests/toolbox/')
from establish_specs import establish_spec

machine_spec_file='/Users/jamesmcc/WRF_Hydro/wrf_hydro_tests/machine_spec.yaml'
candidate_spec_file='/Users/jamesmcc/WRF_Hydro/wrf_hydro_tests/template_candidate_spec.yaml'
user_spec_file='/Users/jamesmcc/WRF_Hydro/wrf_hydro_tests/template_user_spec.yaml'

#def get_sched_args_from_specs(machine_spec_file:   str=None,
#                              user_spec_file:      str=None,
#                              candidate_spec_file: str=None):

# Note: The d3={**d1,**d2} syntax overrides d1 with entries in d2    
# Actually need hierarchical merge that I have used at home...

# The candidate comes first and can replace the machine and user specs files.
# The user spec can overrides parts of the machine spec.
# So, importance: candidate_spec_file > user_spec_file > machine_spec_file

spec={}
if machine_spec_file:
    spec = establish_spec(machine_spec_file)

pprint(spec)

if user_spec_file:
    spec_tmp = establish_spec(user_spec_file)
    if spec:
        spec = { **spec, **spec_tmp }
    else:
        spec = spec_tmp

pprint(spec)

if candidate_spec_file:
    spec_tmp = establish_spec(candidate_spec_file)
    if spec:
        spec = { **spec, **spec_tmp }
    else:
        spec = spec_tmp

pprint(spec)

machine = 'cheyenne'
scheduler_name = spec[machine]['scheduler']['name']
compiler_name = spec['compiler']

# Then need to map to
sched_args_dict = {}
sad = sched_args_dict

#sad['name'] = spec # pass as arg?
sad['account'] = spec[scheduler_name]['account']
sad['email_when'] = spec[scheduler_name]['email']['when']
sad['email_who'] = spec[scheduler_name]['email']['who']
sad['queue'] = spec['queue']
sad['walltime'] = spec['wall_time']
#sad['np'] = spec # pass as arg?
#sad['nodes'] = spec
sad['ppn'] = spec[machine]['cores_per_node']
sad['command'] = spec[machine]['scheduler_name']
sad['sched_name'] = scheduler_name

sad['modules'] = spec[machine]['modules'][compiler_name]
if 'base' in spec[machine]['modules'].keys():
    sad['modules'] += ' ' + spec[machine]['modules']['base']
    


