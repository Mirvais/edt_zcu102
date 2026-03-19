# 2026-02-27T03:12:41.581448
import vitis

client = vitis.create_client()
client.set_workspace(path="Vitis")

platform = client.get_component(name="zcu102_edt")
domain = platform.add_domain(cpu = "psu_cortexr5_0",os = "standalone",name = "standalone_r5",display_name = "standalone_r5",generate_dtb = False,compiler = "gcc")

status = platform.build()

comp = client.get_component(name="hello_a53")
comp.build()

comp = client.create_app_component(name="hello_r5",platform = "$COMPONENT_LOCATION/../zcu102_edt/export/zcu102_edt/zcu102_edt.xpfm",domain = "standalone_r5",template = "hello_world")

proj = client.create_sys_project(name="hello_r5_system", platform="$COMPONENT_LOCATION/../zcu102_edt/export/zcu102_edt/zcu102_edt.xpfm", template="empty_accelerated_application" , build_output_type="xsa")

proj = client.get_sys_project(name="hello_r5_system")

proj = proj.add_component(name="hello_r5")

proj = client.get_sys_project(name="hello_r5_system")

proj.build(build_comps = False)

proj = client.create_sys_project(name="hello_system", platform="$COMPONENT_LOCATION/../zcu102_edt/export/zcu102_edt/zcu102_edt.xpfm", template="empty_accelerated_application" , build_output_type="xsa")

proj = client.get_sys_project(name="hello_system")

proj = client.get_sys_project(name="hello_system")

proj = proj.add_component(name="hello_r5")

proj = proj.add_component(name="hello_a53")

proj = proj.remove_component(name="hello_r5")

proj = client.get_sys_project(name="hello_system")

proj.build(comp_name = ["hello_a53"],build_comps = False)

status = platform.build()

comp.build()

comp = client.create_app_component(name="testapp_r5",platform = "$COMPONENT_LOCATION/../zcu102_edt/export/zcu102_edt/zcu102_edt.xpfm",domain = "standalone_r5",template = "empty_application")

proj = client.get_sys_project(name="hello_system")

proj = proj.add_component(name="testapp_r5")

proj = client.get_sys_project(name="hello_system")

proj.build(comp_name = ["hello_a53"],build_comps = False)

comp = client.get_component(name="testapp_r5")
status = comp.import_files(from_loc="$COMPONENT_LOCATION/..", files=["testapp_r5.c"], dest_dir_in_cmp = "src")

status = platform.build()

comp = client.get_component(name="testapp_r5")
comp.build()

proj.build(build_comps = False)

domain = platform.get_domain(name="standalone_r5")

status = domain.set_config(option = "os", param = "standalone_stdin", value = "psu_uart_1")

status = domain.set_config(option = "os", param = "standalone_stdout", value = "psu_uart_1")

status = platform.build()

status = platform.build()

comp.build()

vitis.dispose()

