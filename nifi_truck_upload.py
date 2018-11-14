import nipyapi
import sys

# brokerlist = 'ip-172-31-86-173.ec2.internal:6667,ip-172-31-88-59.ec2.internal:6667,ip-172-31-80-202.ec2.internal:6667'
brokerlist=sys.argv[1]
print("Brokerlist: " + brokerlist)
nifi_host = sys.argv[2]
print("NiFi Host: " + nifi_host)

# test string: nipyapi.config.nifi_config.host = 'http://ip-172-31-80-202.ec2.internal:9090/nifi-api' 
nipyapi.config.nifi_config.host = 'http://' + nifi_host + ':9090/nifi-api' 
#nipyapi.config.registry_config.host = 'http://localhost:18080/nifi-registry-api'

template_file = "/root/hdp_utils/trucking_non-secure.xml"

# root process group id
root_id = nipyapi.canvas.get_root_pg_id()
print('Root ID is: ' + root_id)

print("Uploading template...")
nifi_template = nipyapi.templates.upload_template(pg_id=root_id, template_file=template_file)

# deploy template
print("Deploying template...")
deployed_template = nipyapi.templates.deploy_template(root_id, nifi_template.id)

all_procs = nipyapi.canvas.list_all_processors(root_id)
kafka_procs = [x for x in all_procs if 'Kafka' in x.component.type]

print("Updating broker list...")
for proc in kafka_procs:
    nipyapi.canvas.update_processor(
        processor=proc,
        update=nipyapi.nifi.ProcessorConfigDTO(
            properties={
                'bootstrap.servers': brokerlist
            }
        )
    )

#nipyapi.canvas.list_all_process_groups() 
	# 'Route, Transform and Enrich' 'Acquire Events from Kafka IOT Gateways' 'Publish Enriched Streams Kafka Syndication Services'
	# IOT Trucking Fleet - Data Flow'

# get parents PG
pg_flow = nipyapi.canvas.get_process_group('IOT Trucking Fleet - Data Flow')
print("Parent Flow ID is: " + pg_flow.id)

# return controller services within PG
cont_services = nipyapi.nifi.FlowApi().get_controller_services_from_group(pg_flow.id)

list_schema_registry = []
list_non_schema_registry = []

for i in range(0,6):
	if cont_services.controller_services[i].component.name == 'HWX Schema Registry':
		list_schema_registry.append(cont_services.controller_services[i])
	else:
		list_non_schema_registry.append(cont_services.controller_services[i])

print("Number of Elements in SR List: " + str(len(list_schema_registry)))
print("Number of Elements in Non-SR List: " + str(len(list_non_schema_registry)))
print("Total number of expected elements: " + str(len(cont_services.controller_services)))

# cont_services.controller_services[i].component.name = 'HWX Schema Registry'

def start_cs(cse, desired_state='ENABLED'):
    return nipyapi.nifi.ControllerServicesApi().update_controller_service(
    id=cse.id,
    body=nipyapi.nifi.ControllerServiceEntity(
        component=nipyapi.nifi.ControllerServiceDTO(
            state=desired_state,
            id=cse.id
        ),
        revision=cse.revision
    )
	)

for cse in list_schema_registry:
	start_cs(cse)

for cse in list_non_schema_registry:
	start_cs(cse)

print("Starting all processors...")
start = nipyapi.canvas.schedule_process_group(pg_flow.id, True)
