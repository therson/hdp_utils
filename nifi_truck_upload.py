import nipyapi
import sys

# brokerlist = 'ip-172-31-80-110.ec2.internal:6667,ip-172-31-89-246.ec2.internal:6667,ip-172-31-89-190.ec2.internal:6667'
brokerlist=sys.argv[1]
nifi_host = sys.argv[2]

# test string: nipyapi.config.nifi_config.host = 'http://ip-172-31-80-110.ec2.internal:9090/nifi-api' 
nipyapi.config.nifi_config.host = 'http://' + nifi_host + ':9090/nifi-api' 
#nipyapi.config.registry_config.host = 'http://localhost:18080/nifi-registry-api'

template_file = "/root/hdp_utils/trucking_non-secure.xml"

# root process group id
root_id = nipyapi.canvas.get_root_pg_id()

nifi_template = nipyapi.templates.upload_template(pg_id=root_id, template_file=template_file)

# deploy template
deployed_template = nipyapi.templates.deploy_template(root_id, nifi_template.id)

all_procs = nipyapi.canvas.list_all_processors(root_id)
kafka_procs = [x for x in all_procs if 'Kafka' in x.component.type]

for proc in kafka_procs:
    nipyapi.canvas.update_processor(
        processor=proc,
        update=nipyapi.nifi.ProcessorConfigDTO(
            properties={
                'bootstrap.servers': brokerlist
            }
        )
    )


control_services_entity = nipyapi.nifi.models.ActivateControllerServicesEntity(deployed_template)

nipyapi.canvas.list_all_process_groups() 
	# 'Route, Transform and Enrich' 'Acquire Events from Kafka IOT Gateways' 'Publish Enriched Streams Kafka Syndication Services'
	# IOT Trucking Fleet - Data Flow'

# get parents PG
pg_flow = nipyapi.canvas.get_process_group('IOT Trucking Fleet - Data Flow')

# return controller services within PG
cont_services = nipyapi.nifi.FlowApi().get_controller_services_from_group(pg_flow.id)
list_cs_in_order = [cont_services.controller_services[5], cont_services.controller_services[3], cont_services.controller_services[0], 
					cont_services.controller_services[1], cont_services.controller_services[2], cont_services.controller_services[4]]

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

for cse in list_cs_in_order:
	start_cs(cse)

# this will fail to start anything that relies on a controller service
start = nipyapi.canvas.schedule_process_group(pg_flow.id, True)


## SAM 
## register environment, register UDFs, connect cluster, modify template, deploy template, start template
## copy superset configs into DB
