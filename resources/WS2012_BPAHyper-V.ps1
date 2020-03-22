# Hyper-V.ps1
# BPA Powershell Discovery Script
# Stefan J. Wernli (swernli)

#
# ----------------
# FALLBACK STRINGS
# ----------------
#
data _system_translations {
ConvertFrom-StringData @'
###PSLOC - Start Localization

    rule1_Title      = Windows hypervisor must be running
    rule1_Problem    = Windows hypervisor is not running.
    rule1_Impact     = Virtual machines cannot be started until Windows hypervisor is running.
    rule1_Resolution = Check the Hyper-V-Hypervisor event log for information.
    rule1_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule2_Title      = The Hyper-V Virtual Machine Management Service must be running
    rule2_Problem    = The service required to manage virtual machines is not running.
    rule2_Impact     = No virtual machine management operations can be performed until the service is started.
    rule2_Resolution = Use the Services snap-in, the Set-Service cmdlet, or sc config command-line tool to reconfigure the service to start automatically.
    rule2_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule21_Title      = The Hyper-V Virtual Machine Management Service should be configured to start automatically
    rule21_Problem    = The Hyper-V Virtual Machine Management Service is not configured to start automatically.
    rule21_Impact     = Virtual machines cannot be managed until the service is started.
    rule21_Resolution = Use the Services snap-in, the Set-Service cmdlet, or sc config command-line tool to reconfigure the service to start automatically.
    rule21_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule24_Title      = Hyper-V should be the only enabled role
    rule24_Problem    = Roles other than Hyper-V are enabled on this server.
    rule24_Impact     = The Hyper-V role should be the only role enabled on a server.
    rule24_Resolution = Use Server Manager to remove all roles except Hyper-V.
    rule24_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule25_Title      = The Server Core installation option is recommended for servers running Hyper-V
    rule25_Problem    = This server is running a full installation instead of a Server Core installation.
    rule25_Impact     = Running a full installation exposes a larger attack surface and may require more maintenance, such as installing updates.
    rule25_Resolution = Reconfigure the server to run a Server Core installation by using Server Manager to remove the features under the User Interfaces and Infrastructure category.
    rule25_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule26_Title      = Domain membership is recommended for servers running Hyper-V
    rule26_Problem    = This server is a member of a workgroup.
    rule26_Impact     = There is no central management for this server.
    rule26_Resolution = If you have a domain environment available, join this server to that domain.
    rule26_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule27_Title      = Avoid pausing a virtual machine
    rule27_Problem    = This server has one or more virtual machines in a paused state.
    rule27_Impact     = Depending on the amount of available memory, you might not be able to run additional virtual machines.
    rule27_Resolution = If this is intentional, no further action is required. Otherwise, consider resuming these virtual machines or shutting them down.
    rule27_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule28_Title      = Offer all available integration services to virtual machines
    rule28_Problem    = One or more available integration services are not enabled on virtual machines.
    rule28_Impact     = Some capabilities will not be available to the following virtual machines: \n{0}
    rule28_Resolution = If this is intentional, no further action is required. Otherwise, consider offering all integration services in the settings of these virtual machines.
    rule28_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule29_Title      = Storage controllers should be enabled in virtual machines to provide access to attached storage
    rule29_Problem    = One or more storage controllers may be disabled in a virtual machine.
    rule29_Impact     = Virtual machines cannot use storage connected to a disabled storage controller. This impacts the following virtual machines:  \n{0}
    rule29_Resolution = Use Device Manager in the guest operating system to enable all storage controllers. If the storage controller is not required, use Hyper-V Manager to remove it from the virtual machine.
    rule29_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule30_Title      = Display adapters should be enabled in virtual machines to provide video capabilities
    rule30_Problem    = The Microsoft Virtual Machine Bus Video Device may be disabled in a virtual machine.
    rule30_Impact     = Video performance for the following virtual machines will be degraded: \n{0}
    rule30_Resolution = Use Device Manager in the guest operating system to enable the Microsoft Virtual Machine Bus Video Device.
    rule30_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule31_Title      = Run the current version of integration services in all guest operating systems
    rule31_Problem    = A virtual machine is running an older version of a driver for one or more integration services.
    rule31_Impact     = Performance might be affected for the following virtual machines: \n{0}
    rule31_Resolution = Use Virtual Machine Connection to install the current version of the integration services in the guest operating system.
    rule31_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule32_Title      = Enable all integration services in virtual machines
    rule32_Problem    = One or more integration services are disabled or not working in a virtual machine.
    rule32_Impact     = The service or integration feature may not operate correctly for the following virtual machines: \n{0}
    rule32_Resolution = Use the Services snap-in or sc config command-line tool to verify that the service is configured to start automatically and is not stopped.
    rule32_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule51_Title      = The number of logical processors in use must not exceed the supported maximum
    rule51_Problem    = The server is configured with too many logical processors.
    rule51_Impact     = Microsoft does not support running Hyper-V on this computer.
    rule51_Resolution = Remove some processors from this machine or use msconfig to limit the number of available processors.
    rule51_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule53_Title      = Use RAM that provides error correction
    rule53_Problem    = The RAM in use on this computer is not error-correcting (ECC) RAM.
    rule53_Impact     = Microsoft does not support {0} on computers without error-correcting RAM.
    rule53_Resolution = Verify the server is listed in the Windows Server catalog and qualified for Hyper-V.
    rule53_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule54_Title      = The number of running or configured virtual machines must be within supported limits
    rule54_Problem    = More virtual machines are running or configured than are supported.
    rule54_Impact     = Microsoft does not support the current number of virtual machines running or configured on this server.
    rule54_Resolution = Move one or more virtual machines to another server.
    rule54_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule55_Title      = Second-level address translation is required when running virtual machines enabled for RemoteFX
    rule55_Problem    = Virtual machines enabled with a RemoteFX 3D video adapter require a physical computer with a processor that supports second level address translation (SLAT).
    rule55_Impact     = Microsoft does not support the use of RemoteFX on a server with processors that do not provide SLAT.
    rule55_Resolution = Move the RemoteFX-enabled virtual machines to a physical computer that has processors with SLAT.
    rule55_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule56_Title      = At least one GPU on the physical computer should support RemoteFX and meet the minimum requirements for DirectX when virtual machines are configured with a RemoteFX 3D video adapter
    rule56_Problem    = The physical computer has no graphics processing units (GPUs) that support RemoteFX and that meet the minimum requirements for DirectX.
    rule56_Impact     = Microsoft does not provide support for RemoteFX-enabled virtual machines on physical computers that lack valid GPUs.
    rule56_Resolution = Install at least one supported GPU on the physical computer.
    rule56_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule57_Title      = Avoid installing RemoteFX on a computer that is configured as an Active Directory domain controller
    rule57_Problem    = RemoteFX is installed on a domain controller.
    rule57_Impact     = Virtual machines configured for RemoteFX cannot be used on this computer.
    rule57_Resolution = Decide whether you want to this computer configured for RemoteFX or as an Active Directory domain controller, then reconfigure the computer if necessary.
    rule57_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule59_Title      = Use at least SMB protocol version 3.0 for file shares that store files for virtual machines.
    rule59_Problem    = Virtual machine files or virtual hard disk files are stored on a file share that does not support at least SMB protocol version 3.0.
    rule59_Impact     = Microsoft does not support this configuration. This impacts the following virtual machines:\n{0}
    rule59_Resolution = Move the files to a file share that uses at least SMB protocol version 3.0.
    rule59_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule60_Title      = Use at least SMB protocol version 3.0 configured for continuous availability on file shares that store files for virtual machines.
    rule60_Problem    = Virtual machine files or virtual hard disk files are stored on a network file share that is not configured with the continuous availability feature of SMB protocol version 3.0.
    rule60_Impact     = Microsoft does not recommend this configuration because it might impact the availability of the virtual machines using the file server. This impacts the following virtual machines:\n{0}
    rule60_Resolution = Do one of the following: \n\t1. Move the files to an SMB 3.0 file share that is configured for continuous availability.\n\t2. Reconfigure the current file share to provide continuous availability.
    rule60_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule201_Title      = Configure at least the required amount of memory for a virtual machine running Windows Server 2003 and enabled for Dynamic Memory
    rule201_Problem    = One or more virtual machines are configured to use Dynamic Memory with less than the amount of memory required for Windows Server 2003.
    rule201_Impact     = The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
    rule201_Resolution = Use Hyper-V Manager or Windows PowerShell to increase the minimum memory, startup memory and maximum memory to at least 128 MB.
    rule201_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule202_Title      = A virtual machine running Windows Server 2003 and configured with Dynamic Memory should use recommended values for memory settings
    rule202_Problem    = One or more virtual machines are configured to use Dynamic Memory with less than the amount of memory recommended for Windows Server 2003.
    rule202_Impact     = The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
    rule202_Resolution = Use Hyper-V Manager or Windows PowerShell to increase the minimum memory and startup memory to at least 128 MB and maximum memory to at least 256 MB.
    rule202_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule203_Title      = Configure at least the required amount of memory for a virtual machine running Windows Server 2008 and enabled for Dynamic Memory
    rule203_Problem    = One or more virtual machines are configured to use Dynamic Memory with less than the amount of memory required for Windows Server 2008.
    rule203_Impact     = The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
    rule203_Resolution = Use Hyper-V Manager or Windows PowerShell to increase the minimum memory to at least 256 MB, and the startup memory and maximum memory to at least 512 MB.
    rule203_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule204_Title      = A virtual machine running Windows Server 2008 and configured with Dynamic Memory should use recommended values for memory settings
    rule204_Problem    = One or more virtual machines are configured to use Dynamic Memory with less than the amount of memory recommended for Windows Server 2008.
    rule204_Impact     = The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
    rule204_Resolution = Use Hyper-V Manager or Windows PowerShell to increase the minimum memory to at least 256 MB, startup memory to at least 512 MB and maximum memory to at least 2 GB.
    rule204_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule205_Title      = Configure at least the required amount of memory for a virtual machine running Windows Vista and enabled for Dynamic Memory
    rule205_Problem    = One or more virtual machines are configured to use Dynamic Memory with less than the amount of memory required for Windows Vista.
    rule205_Impact     = The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
    rule205_Resolution = Use Hyper-V Manager or Windows PowerShell to increase the minimum memory to at least 256 MB, and the startup memory and maximum memory to at least 512 MB.
    rule205_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule206_Title      = A virtual machine running Windows Vista and configured with Dynamic Memory should use recommended values for memory settings
    rule206_Problem    = One or more virtual machines are configured to use Dynamic Memory with less than the amount of memory recommended for Windows Vista.
    rule206_Impact     = The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
    rule206_Resolution = Use Hyper-V Manager or Windows PowerShell to increase the minimum memory to at least 256 MB, startup memory to at least 512 MB and maximum memory to at least 1 GB.
    rule206_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule207_Title      = Configure at least the required amount of memory for a virtual machine running Windows Server 2008 R2 and enabled for Dynamic Memory
    rule207_Problem    = One or more virtual machines are configured to use Dynamic Memory with less than the amount of memory  required for Windows Server 2008 R2.
    rule207_Impact     = The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
    rule207_Resolution = Use Hyper-V Manager or Windows PowerShell to increase the minimum memory to at least 256 MB, and the startup memory and maximum memory to at least 512 MB.
    rule207_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule208_Title      = A virtual machine running Windows Server 2008 R2 and configured with Dynamic Memory should use recommended values for memory settings
    rule208_Problem    = One or more virtual machines are configured to use Dynamic Memory with less than the amount of memory  recommended for Windows Server 2008 R2.
    rule208_Impact     = The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
    rule208_Resolution = Use Hyper-V Manager or Windows PowerShell to increase the minimum memory to at least 256 MB, startup memory to at least 512 MB and maximum memory to at least 2 GB.
    rule208_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule209_Title      = Configure at least the required amount of memory for a virtual machine running Windows 7 and enabled for Dynamic Memory
    rule209_Problem    = One or more virtual machines are configured to use Dynamic Memory with less than the amount of memory required for Windows 7.
    rule209_Impact     = The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
    rule209_Resolution = Use Hyper-V Manager or Windows PowerShell to increase the minimum memory to at least 256 MB, and the startup memory and maximum memory to at least 512 MB.
    rule209_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule210_Title      = A virtual machine running Windows 7 and configured with Dynamic Memory should use recommended values for memory settings
    rule210_Problem    = One or more virtual machines are configured to use Dynamic Memory with less than the amount of memory recommended for Windows 7.
    rule210_Impact     = The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
    rule210_Resolution = Use Hyper-V Manager or Windows PowerShell to increase the minimum memory to at least 256 MB, startup memory to at least 512 MB and maximum memory to at least 1 GB.
    rule210_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule211_Title      = Configure at least the required amount of memory for a virtual machine running {1} and enabled for Dynamic Memory
    rule211_Problem    = One or more virtual machines are configured to use Dynamic Memory with less than the amount of memory required for {1}.
    rule211_Impact     = The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
    rule211_Resolution = Use Hyper-V Manager to increase the minimum memory to at least 256 MB, and the startup memory and maximum memory to at least 512 MB for this virtual machine.
    rule211_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule212_Title      = A virtual machine running {1} and configured with Dynamic Memory should use recommended values for memory settings
    rule212_Problem    = One or more virtual machines are configured to use Dynamic Memory with less than the amount of memory recommended for {1}.
    rule212_Impact     = The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
    rule212_Resolution = Use Hyper-V Manager to increase the minimum memory to at least 256 MB, startup memory to at least 512 MB and maximum memory to at least 2 GB for this virtual machine.
    rule212_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule213_Title      = Configure at least the required amount of memory for a virtual machine running {1} and enabled for Dynamic Memory
    rule213_Problem    = One or more virtual machines are configured to use Dynamic Memory with less than the amount of memory required for {1}.
    rule213_Impact     = The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
    rule213_Resolution = Use Hyper-V Manager to increase the minimum memory to at least 256 MB, and the startup memory and maximum memory to at least 512 MB for this virtual machine.
    rule213_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule214_Title      = A virtual machine running {1} and configured with Dynamic Memory should use recommended values for memory settings
    rule214_Problem    = One or more virtual machines are configured to use Dynamic Memory with less than the amount of memory recommended for {1}.
    rule214_Impact     = The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
    rule214_Resolution = Use Hyper-V Manager to increase the minimum memory to at least 256 MB, startup memory to at least 512 MB and maximum memory to at least 1 GB for this virtual machine.
    rule214_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule215_Title      = Dynamic Memory is enabled but not responding on some virtual machines
    rule215_Problem    = One or more virtual machines are experiencing problems with the driver required for Dynamic Memory in the guest operating system.
    rule215_Impact     = The guest operating system in the following virtual machines might not run or might run unreliably because Hyper-V cannot adjust the memory dynamically to respond to changes in memory demand. This impacts the following virtual machines:\n{0}
    rule215_Resolution = This is expected behavior if the virtual machine is booting. If the virtual machine is not booting, make sure that integration services are upgraded to the latest version and that the guest operating system supports Dynamic Memory.
    rule215_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule216_Title      = Avoid storing Smart Paging files on a system disk
    rule216_Problem    = The memory configuration for one or more virtual machines might require the use of Smart Paging if the virtual machine is rebooted, and the specified location for the Smart Paging file is the system disk of the server running Hyper-V.
    rule216_Impact     = Use of the system disk for Smart Paging might cause the server running Hyper-V to experience problems. This affects the following virtual machines:\n{0}
    rule216_Resolution = Reconfigure the virtual machines to store the Smart Paging files on a non-system disk.
    rule216_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule226_Title      = A Replica server must be configured to accept replication requests
    rule226_Problem    = This computer is designated as a Hyper-V Replica server but is not configured to accept incoming replication data from primary servers.
    rule226_Impact     = This server cannot accept replication traffic from primary servers.
    rule226_Resolution = Use Hyper-V Manager to specify which primary servers this Replica server should accept replication data from.
    rule226_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule227_Title      = Replica servers should be configured to identify specific primary servers authorized to send replication traffic
    rule227_Problem    = As configured, this Replica server accepts replication traffic from all primary servers and stores them in a single location.
    rule227_Impact     = All replication from all primary servers is stored in one location, which might introduce privacy or security problems.
    rule227_Resolution = Use Hyper-V Manager to create new authorization entries for the specific primary servers and specify separate storage locations for each of them. You can use wildcard characters to group primary servers into sets for each authorization entry.
    rule227_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule228_Title      = Compression is recommended for replication traffic
    rule228_Problem    = The replication traffic sent across the network from the primary server to the Replica server is uncompressed.
    rule228_Impact     = Replication traffic will use more bandwidth than necessary. This impacts the following virtual machines:\n{0}
    rule228_Resolution = Configure Hyper-V Replica to compress the data transmitted over the network in the settings for the virtual machine in Hyper-V Manager. You can also use tools outside of Hyper-V to perform compression.
    rule228_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule229_Title      = Configure guest operating systems for VSS-based backups to enable application-consistent snapshots for Hyper-V Replica
    rule229_Problem    = Application-consistent snapshots requires that Volume Shadow Copy Services (VSS) is enabled and configured in the guest operating systems of virtual machines participating in replication.
    rule229_Impact     = Even if application-consistent snapshots are specified in the replication configuration, Hyper-V will not use them unless VSS is configured. This impacts the following virtual machines:\n{0}
    rule229_Resolution = Use Virtual Machine Connection to install integration services in the virtual machine.
    rule229_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule230_Title      = Integration services must be installed before primary or Replica virtual machines can use an alternate IP address after a failover
    rule230_Problem    = Virtual machines participating in replication can be configured to use a specific IP address in the event of failover, but only if integration services are installed in the guest operating system of the virtual machine.
    rule230_Impact     = In the event of a failover (planned, unplanned, or test), the Replica virtual machine will come online using the same IP address as the primary virtual machine. This configuration might cause connectivity issues. This impacts the following virtual machines:\n{0}
    rule230_Resolution = Use Virtual Machine Connection to install integration services in the virtual machine.
    rule230_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule231_Title      = Authorization entries should have distinct tags for primary servers with virtual machines that are not part of the same security group.
    rule231_Problem    = The server will accept replication requests for the replica virtual machine from any of the servers in the authorization list associated with the same replication tag as the virtual machine.
    rule231_Impact     = There might be privacy and security concerns with a virtual machine accepting replication from primary servers belonging to different authorization entries. This impacts the following authorization entries:\n{0}
    rule231_Resolution = Use different tags in the authorization entries for primary servers with virtual machines that are not part of the same security group. Modify the Hyper-V settings to configure the replication tags.
    rule231_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule232_Title      = To participate in replication, servers in failover clusters must have a Hyper-V Replica Broker configured
    rule232_Problem    = For failover clusters, Hyper-V Replica requires the use of a Hyper-V Replica Broker name instead of an individual server name.
    rule232_Impact     = If the virtual machine is moved to a different failover cluster node, replication cannot continue.
    rule232_Resolution = Use Failover Cluster Manager to configure the Hyper-V Replica Broker. In Hyper-V Manager, ensure that the replication configuration uses the Hyper-V Replica Broker name as the server name.
    rule232_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule233_Title      = Certificate-based authentication is recommended for replication.
    rule233_Problem    = One or more virtual machines selected for replication are configured for Kerberos authentication.
    rule233_Impact     = The replication network traffic from the primary server to the replication server is unencrypted. This impacts the following virtual machines:\n{0}
    rule233_Resolution = If another method is being used to perform encryption, you can ignore this. Otherwise, modify the virtual machine settings to choose certificate-based authentication.
    rule233_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule234_Title      = Virtual hard disks with paging files should be excluded from replication
    rule234_Problem    = Paging files should be excluded from participating in replication, but no disks have been excluded.
    rule234_Impact     = Paging files experience a high volume of input/output activity, which will unnecessarily require much greater resources to participate in replication. This impacts the following virtual machines:\n{0}
    rule234_Resolution = If you have not already done so, create a separate virtual hard disk for the Windows paging file. If initial replication has already been completed, use Hyper-V Manager to remove replication. Then, configure replication again and exclude the virtual hard disk with the paging file from replication.
    rule234_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule235_Title      = Configure a policy to throttle the replication traffic on the network
    rule235_Problem    = There might not be a limit on the amount of network bandwidth that replication is allowed to consume.
    rule235_Impact     = Network bandwidth could become completely dominated by replication traffic, affecting other critical network activity. This impacts the following ports:\n{0}
    rule235_Resolution = If you use another method to throttle network traffic, you can ignore this. Otherwise, use Group Policy Editor to configure a policy that will throttle the network traffic to the relevant port of the Replica server.
    rule235_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule236_Title      = Configure the Failover TCP/IP settings that you want the Replica virtual machine to use in the event of a failover
    rule236_Problem    = Replica virtual machines configured with a static IP address should be configured to use a different IP address from their primary virtual machine counterpart in the event of failover.
    rule236_Impact     = Clients using the workload supported by the primary virtual machine might not be able to connect to the Replica virtual machine after a failover. Also, the primary virtual machine's original IP address will not be valid in the Replica virtual machine network topology. This impacts the following virtual machine(s):\n{0}
    rule236_Resolution = Use Hyper-V Manager to configure the IP address that the Replica virtual machine should use in the event of failover.
    rule236_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule237_Title      = Resynchronization of replication should be scheduled for off-peak hours
    rule237_Problem    = Resynchronization of replication for the primary virtual machines is not scheduled for off-peak hours.
    rule237_Impact     = The longer a virtual machine is in a state requiring resynchronization, the longer the replication log files grow and the more unreplicated changes occur on the primary virtual machines. This impacts the following virtual machines:\n{0}
    rule237_Resolution = Use Hyper-V Manager to modify the replication settings for the virtual machine to perform resynchronization automatically during off-peak hours.
    rule237_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule238_Title      = Certificate-based authentication is configured, but the specified certificate is not installed on the Replica server or failover cluster nodes
    rule238_Problem    = The security certificate that Hyper-V Replica has been configured to use to provide certificate-based replication is not installed on the Replica server (or any failover cluster nodes).
    rule238_Impact     = In the event of a cluster failover or move to another node, Hyper-V replication will pause if the new node does not also have the appropriate certificate installed. This impacts the following nodes:\n{0}
    rule238_Resolution = Install the configured certificate on the Replica server (and all associated nodes in the failover cluster, if any).
    rule238_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule239_Title      = Replication is paused for one or more virtual machines on this server
    rule239_Problem    = Replication is paused for one or more of the virtual machines. While the primary virtual machine is paused, any changes that occur will be accumulated and will be sent to the Replica virtual machine once replication is resumed.
    rule239_Impact     = As long as replication is paused, accumulated changes occurring in the primary virtual machine will consume available disk space on the primary server. After replication is resumed, there might be a large burst of network traffic to the Replica server. This impacts the following virtual machines:\n{0}
    rule239_Resolution = Confirm that pausing replication was intended. If replication was paused to address low disk space or network connectivity, resume replication as soon as those issues are resolved.
    rule239_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule240_Title      = Test failover should be attempted after initial replication is complete
    rule240_Problem    = No test failovers have been attempted after completing initial replication.
    rule240_Impact     = There is no confirmation that a planned or unplanned failover will succeed or workload operations will continue properly after a failover. This impacts the following virtual machines:\n{0}
    rule240_Resolution = Use Hyper-V Manager to conduct a test failover.
    rule240_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule241_Title      = Test failovers should be carried out at least monthly to verify that failover will succeed and that virtual machine workloads will operate as expected after failover
    rule241_Problem    = There has been no test failover in at least one month.
    rule241_Impact     = There is no confirmation that a planned or unplanned failover will succeed or workload operations will continue properly after a failover. This impacts the following virtual machines:\n{0}
    rule241_Resolution = Use Hyper-V Manager to conduct a test failover.
    rule241_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule244_Title      = VHDX-format virtual hard disks are recommended for virtual machines that have recovery history enabled in replication settings
    rule244_Problem    = VHD-format virtual hard disks are being used for virtual machines that are enabled for replication with recovery history.
    rule244_Impact     = Under some circumstances, the VHD-format virtual hard disks on the Replica server could experience consistency issues. This impacts the following virtual machines:\n{0}
    rule244_Resolution = Use the VHDX format for virtual hard disks used in virtual machines that are enabled for replication with recovery history. The VHDX format has reliability mechanisms that help protect the disk from corruptions due to system power failures. You can convert a virtual hard disk from VHD format to VHDX format. However, do not convert the virtual hard disk if it is likely to be attached to an earlier release of Windows at some point. Windows releases earlier than {1} do not support the VHDX format.
    rule244_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule245_Title      = Recovery snapshots should be removed after failover
    rule245_Problem    = A failed over virtual machine has one or more recovery snapshots.
    rule245_Impact     = Available space may run out on the physical disk that stores the snapshot files. If this occurs, no additional disk operations can be performed on the physical storage. Any virtual machine that relies on the physical storage could be affected. This impacts the following virtual machines:\n{0}
    rule245_Resolution = For each failed over virtual machine, use the Complete-VMFailover cmdlet in Windows PowerShell to remove the recovery snapshots and indicate failover completion.
    rule245_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule251_Title      = At least one network for live migration traffic should have a link speed of at least 1 Gbps
    rule251_Problem    = None of the networks for live migration traffic have a link speed of at least 1 Gbps.
    rule251_Impact     = Live migrations might occur slowly, which could disrupt the network connection due to a TCP connection timeout.
    rule251_Resolution = Configure at least one live migration network with a speed of 1 Gbps or faster.
    rule251_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule252_Title      = All networks for live migration traffic should have a link speed of at least 1 Gbps
    rule252_Problem    = The link speed is less than 1 Gbps on some networks for live migration.
    rule252_Impact     = Live migrations might occur slowly, which could disrupt the network connection due to a TCP connection timeout.
    rule252_Resolution = Verify that all live migration networks are configured for a speed of 1 Gbps or faster.
    rule252_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule300_Title      = Virtual machines should be backed up at least once every week
    rule300_Problem    = One or more virtual machines have not been backed up in the past week.
    rule300_Impact     = Significant data loss might occur if the virtual machine encounters a problem and a recent backup does not exist. This impacts the following virtual machines:\n{0}
    rule300_Resolution = Schedule a backup of the virtual machines to run at least once a week. You can ignore this rule if this virtual machine is a replica and its primary virtual machine is being backed up, or if this is the primary virtual machine and its replica is being backed up.
    rule300_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule351_Title      = Ensure sufficient physical disk space is available when virtual machines use dynamically expanding virtual hard disks
    rule351_Problem    = One or more virtual machines are using dynamically expanding virtual hard disks
    rule351_Impact     = Dynamically expanding virtual hard disks require available space on the hosting volume so that space can be allocated when writes to the virtual hard disks occur. If available space is exhausted, any virtual machine that relies on the physical storage could be affected. This impacts the following virtual machines:\n{0}
    rule351_Resolution = Monitor available disk space to ensure sufficient space is available for expansion. Consider shutting down the virtual machine and use the Edit Disk Wizard in Hyper-V Manager to convert each dynamically expanding virtual hard disk for this virtual machine to a fixed sized virtual hard disk.
    rule351_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule352_Title      = Ensure sufficient physical disk space is available when virtual machines use differencing virtual hard disks
    rule352_Problem    = One or more virtual machines are using differencing virtual hard disks.
    rule352_Impact     = Differencing virtual hard disks require available space on the hosting volume so that space can be allocated when writes to the virtual hard disks occur. If available space is exhausted, any virtual machine that relies on the physical storage could be affected. This impacts the following virtual machines:\n{0}
    rule352_Resolution = Monitor available disk space to ensure sufficient space is available for virtual hard disk expansion. Consider merging differencing virtual hard disks into their parent. In Hyper-V Manager, inspect the differencing disk to determine the parent virtual hard disk. If you merge a differencing disk to a parent disk that is shared by other differencing disks, that action will corrupt the relationship between the other differencing disks and the parent disk, making them unusable. After verifying that the parent virtual hard disk is not shared, you can use the Edit Disk Wizard to merge the differencing disk to the parent virtual hard disk.
    rule352_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule353_Title      = Avoid alignment inconsistencies between virtual blocks and physical disk sectors on dynamic virtual hard disks or differencing disks
    rule353_Problem    = Alignment inconsistencies were detected for one or more virtual hard disks.
    rule353_Impact     = If the virtual hard disks are stored on physical disk that has a sector size of 4K, the virtual machine or applications that use the virtual hard disk might experience performance problems. This affects the following virtual machines:\n{0}
    rule353_Resolution = Use the Create Virtual Hard Disk Wizard to create a new VHD-format or VHDX-format virtual hard disk and specify the existing virtual hard disk as the source disk. The new virtual hard disk will be created with alignment between the virtual blocks and physical disk.
    rule353_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule354_Title      = VHD-format dynamic virtual hard disks are not recommended for virtual machines that run server workloads in a production environment
    rule354_Problem    = One or more virtual machines use VHD-format dynamically expanding virtual hard disks.
    rule354_Impact     = VHD-format dynamic virtual hard disks could experience consistency issues if a power failure occurs. Consistency issues can happen if the physical disk performs an incomplete or incorrect update to a sector in a .vhd file that is being modified when a power failure occurs. This affects the following virtual machines:\n{0}
    rule354_Resolution = Shut down the virtual machine and convert the VHD-format dynamic virtual hard disk to a VHDX-format virtual hard disk or to a fixed virtual hard disk. (The VHDX format has reliability mechanisms that help protect the disk from corruptions due to system power failures.) However, do not convert the virtual hard disk if it is likely to be attached to an earlier release of Windows at some point. Windows releases earlier than {1} do not support the VHDX format.
    rule354_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule355_Title      = Avoid using VHD-format differencing virtual hard disks on virtual machines that run server workloads in a production environment.
    rule355_Problem    = One or more virtual machines use VHD-format differencing virtual hard disks.
    rule355_Impact     = VHD-format differencing virtual hard disks could experience consistency issues if a power failure occurs. Consistency issues can happen if the physical disk performs an incomplete or incorrect update to a sector in a .vhd file that is being modified when a power failure occurs. This affects the following virtual machines:\n{0}
    rule355_Resolution = Shut down the virtual machine and convert the chain of VHD-format differencing virtual hard disks to the VHDX format or merge the chain to a fixed virtual hard disk. (The VHDX format has reliability mechanisms that help protect the disk from corruptions due to power failures.) However, do not convert the virtual hard disk if it is likely to be attached to an earlier release of Windows at some point. Windows releases earlier than {1} do not support the VHDX format.
    rule355_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule401_Title      = Use all virtual functions for networking when they are available
    rule401_Problem    = Some hardware acceleration capabilities are not being utilized.
    rule401_Impact     = This configuration might cause overall CPU utilization to be higher than necessary. Networking performance might not be optimal on the following virtual machines:\n{0}
    rule401_Resolution = Consider configuring the virtual network adapter for SR-IOV if the physical hardware supports SR-IOV and if this configuration does not conflict with the networking features required by the virtual machine.
    rule401_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule402_Title      = The number of running virtual machines configured for SR-IOV should not exceed the number of virtual functions available to the virtual machines
    rule402_Problem    = There are not enough virtual functions available for the number of running virtual machines configured for single-root I/O virtualization (SR-IOV).
    rule402_Impact     = Networking performance might not be optimal on the following virtual machines: \n{0}
    rule402_Resolution = Consider disabling SR-IOV on one or more virtual machines that do not require an SR-IOV virtual function.
    rule402_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule403_Title      = Configure virtual machines to use SR-IOV only when supported by the guest operating system
    rule403_Problem    = One or more virtual machines are configured to use single-root I/O virtualization (SR-IOV), but the guest operating system does not support SR-IOV.
    rule403_Impact     = SR-IOV virtual functions will not be allocated to the following virtual machines:\n{0}
    rule403_Resolution = Disable SR-IOV on all virtual machines that run guest operating systems which do not support SR-IOV.
    rule403_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule404_Title      = Ensure that the virtual function driver operates correctly when a virtual machine is configured to use SR-IOV
    rule404_Problem    = The virtual function driver is not operating correctly in the guest operating system of one or more virtual machines.
    rule404_Impact     = Networking performance is not optimal on the following virtual machines:\n{0}
    rule404_Resolution = In the guest operating system, do the following: Verify that appropriate drivers are installed and all networking devices are enabled, and check the Event log for errors or warnings.
    rule404_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule426_Title      = Configure the server with a sufficient amount of dynamic MAC addresses
    rule426_Problem    = The number of available dynamic MAC addresses is low.
    rule426_Impact     = When no dynamic MAC addresses are available, virtual machines configured to use a dynamic MAC address cannot be started.
    rule426_Resolution = Use Virtual Switch Manager to view and extend the range of dynamic addresses.
    rule426_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule427_Title      = More than one network adapter should be available
    rule427_Problem    = This server is configured with one network adapter, which must be shared by the management operating system and all virtual machines that require access to a physical network.
    rule427_Impact     = Networking performance may be degraded in the management operating system.
    rule427_Resolution = Add more network adapters to this computer. To reserve one network adapter for exclusive use by the management operating system, do not configure it for use with an external virtual network.
    rule427_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule429_Title      = All virtual network adapters should be enabled
    rule429_Problem    = One or more virtual network adapters associated with a physical network adapter are disabled in the management operating system.
    rule429_Impact     = The configuration of this server is not optimal.
    rule429_Resolution = Use Network Connections to enable the virtual network adapter. Or, use Virtual Switch Manager to reconfigure the external virtual network so that it is not shared with the management operating system.
    rule429_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule430_Title      = Enable all virtual network adapters configured for a virtual machine
    rule430_Problem    = One or more network adapters may be disabled in a virtual machine.
    rule430_Impact     = The following virtual machines might not have network connectivity: \n{0}
    rule430_Resolution = Use Device Manager in the guest operating system to enable all virtual network adapters. If the adapter is not required, use Hyper-V Manager to remove it from the virtual machine.
    rule430_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule431_Title      = Avoid using a legacy network adapter on Windows Server 2003 (x64) and Windows XP Professional (x64)
    rule431_Problem    = A virtual machine is configured with a legacy network adapter for which no driver is available.
    rule431_Impact     = Affected virtual machines cannot use a legacy network adapter to provide network connectivity. A legacy network adapter will not work without a network driver. The following virtual machines are configured with a legacy network adapter: \n{0}
    rule431_Resolution = Use Hyper-V Manager to shut down the virtual machine and remove the legacy network adapter. If the virtual machine needs network connectivity, it requires at least one network adapter. If integration services are available, make sure they are installed.
    rule431_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule432_Title      = Avoid using legacy network adapters when the guest operating system supports network adapters
    rule432_Problem    = A guest operating system that supports a network adapter is configured with a legacy network adapter. This configuration is not recommended.
    rule432_Impact     = Networking performance may be degraded for the following virtual machines:\n{0}
    rule432_Resolution = Use Hyper-V Manager to shut down the virtual machine and remove the legacy network adapter. If the virtual machine needs network connectivity, it requires at least one network adapter. If integration services are available, make sure they are installed.
    rule432_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule433_Title      = Ensure that all mandatory virtual switch extensions are available
    rule433_Problem    = One or more virtual network adapters are connected to a virtual switch with mandatory extensions that are disabled or not installed.
    rule433_Impact     = Network traffic is blocked on one or more virtual network adapters on the following virtual machines:\n{0}
    rule433_Resolution = First, make sure that the mandatory extension has been installed on the host and install the extension if necessary. Then, if the mandatory extension is disabled, use Virtual Switch Manager or the Windows PowerShell cmdlet Enable-VMSwitchExtension to enable the extension.
    rule433_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule434_Title      = A team bound to a virtual switch should only have one exposed team interface
    rule434_Problem    = One or more virtual switches are bound to a team that has multiple team interfaces.
    rule434_Impact     = The following virtual switches might not have access to VLANs and bandwidth used by other team interfaces:\n{0}
    rule434_Resolution = Use the Windows PowerShell cmdlet Remove-NetLbfoTeamNic to remove all team interfaces from the team other than the default team interface.
    rule434_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule435_Title      = The team interface bound to a virtual switch should be in default mode
    rule435_Problem    = Some virtual switches are bound to a team interface but the team interface doesn’t pass traffic on all VLANs to the virtual switches.
    rule435_Impact     = The following virtual switches cannot have access to all VLANs: \n{0}
    rule435_Resolution = Use Server Manager or the Windows PowerShell cmdlet Set-NetLbfoTeamNic to reset the team interface to the default mode.
    rule435_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.
    
    rule436_Title      = VMQ should be enabled on VMQ-capable physical network adapters bound to an external virtual switch
    rule436_Problem    = The following network adapters are capable of (virtual machine queue) VMQ but the capability is disabled.
    rule436_Impact     = Windows is unable to take full advantage of available hardware offloads on the following network adapters: \n{0}
    rule436_Resolution = Enable VMQ using the Enable-NetAdapterVmq Powershell cmdlet or using the Advanced Properties user interface for the network adapter.
    rule436_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.
    
    rule437_Title      = One or more network adapters should be configured as the destination for Port Mirroring
    rule437_Problem    = One or more virtual machines have a network adapter configured as a source for Port Mirroring, but there is no corresponding destination on the virtual switch.
    rule437_Impact     = Port Mirroring will not operate correctly for the following virtual switches and virtual machines:\n{0}
    rule437_Resolution = Use PowerShell or Hyper-V Manager to complete or correct the Port Mirroring configuration.
    rule437_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.
    
    rule438_Title      = One or more network adapters should be configured as the source for Port Mirroring
    rule438_Problem    = One or more virtual machines have a network adapter configured as a destination for Port Mirroring, but there is no corresponding source on the virtual switch.
    rule438_Impact     = Port Mirroring will not operate correctly for the following virtual switches and virtual machines:\n{0}
    rule438_Resolution = Use PowerShell or Hyper-V Manager to complete or correct the Port Mirroring configuration.
    rule438_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.
    
    rule439_Title      = PVLAN configuration on a virtual switch must be consistent
    rule439_Problem    = Private Virtual Local Area Network (PVLAN) is not configured correctly on one or more virtual network adapters
    rule439_Impact     = PVLAN might not isolate network traffic between virtual machines correctly. Error code:\n{0}
    rule439_Resolution = Use the Windows PowerShell cmdlet, Set-VMNetworkAdapterVlan, to configure PVLAN correctly.
    rule439_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.
    
    rule440_Title      = The WFP virtual switch extension should be enabled if it is required by third party extensions
    rule440_Problem    = The Windows Filtering Platform (WFP) virtual switch extension is disabled.
    rule440_Impact     = Some third party virtual switch extensions may not operate correctly on the following virtual switches:\n{0}
    rule440_Resolution = Use the Windows PowerShell cmdlet, Enable-VMSwitchExtension, to enable the Windows Filtering Platform if it is required by third party extensions.
    rule440_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule476_Title      = A virtual SAN should be associated with a physical host bus adapter
    rule476_Problem    = A virtual storage area network (SAN) has been configured without an association to a host bus adapter (HBA).
    rule476_Impact     = A virtual machine will fail to start when it is configured with a virtual Fibre Channel adapter connected to a misconfigured virtual SAN. This impacts the following virtual SANs:\n{0}
    rule476_Resolution = Reconfigure the virtual SAN by connecting it to a host bus adapter.
    rule476_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule477_Title      = Virtual machines configured with a virtual Fibre Channel adapter should be configured for high availability to the Fibre Channel-based storage
    rule477_Problem    = One or more virtual machines lack a highly available connection to Fibre Channel-based storage because those virtual machines are configured with a virtual Fibre Channel adapter that is connected to only one host bus adapter (HBA).
    rule477_Impact     = A failure of the host bus adapter might block the Fibre Channel connection between the storage and the virtual machines. This impacts the following virtual machines:\n{0}
    rule477_Resolution = Add another connection from the virtual machine to the host bus adapter and configure multipath I/O (MPIO) in the guest operating system to establish redundant Fibre Channel connections.
    rule477_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.
    
    rule478_Title      = Avoid enabling virtual machines configured with virtual Fibre Channel adapters to allow live migrations when there are fewer paths to Fibre Channel logical units (LUNs) on the destination than on the source
    rule478_Problem    = One or more virtual machines have the AllowReducedFcRedunancy property set in the virtualization WMI provider.
    rule478_Impact     = Live migration of the following virtual machines might lead to data loss or interrupt I/O to storage:/n {0}
    rule478_Resolution = Consider clearing the AllowReducedFcRedundancy  WMI property on the affected virtual machines. When this property is cleared, you can perform a live migration on virtual machines configured with virtual Fibre Channel adapters only when the number of paths to Fibre Channel on the destination is the same or more than the number of paths on the source. These checks help prevent loss of data or interruption of I/O to the storage.
    rule478_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule500_Title      = Configure virtual machines running Windows Server 2003 with 1 or 2 virtual processors
    rule500_Problem    = A virtual machine running Windows Server 2003 is configured with more than 2 virtual processors.
    rule500_Impact     = Microsoft does not support the configuration of the following virtual machines: \n{0}
    rule500_Resolution = Shut down the virtual machine and remove one or more virtual processors.
    rule500_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule502_Title      = Configure virtual machines running Windows Vista with 1 or 2 virtual processors
    rule502_Problem    = A virtual machine running Windows Vista is configured with more than 2 virtual processors.
    rule502_Impact     = Microsoft does not support the configuration of the following virtual machines: \n{0}
    rule502_Resolution = Shut down the virtual machine and remove one or more virtual processors.
    rule502_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.
        
    rule503_Title      = Configure virtual machines running Windows XP Professional SP2 (x86) with 1 virtual processor
    rule503_Problem    = A virtual machine running Windows XP Professional Service Pack 2 (x86) is configured with more than 1 virtual processor.
    rule503_Impact     = Microsoft does not support the configuration of the following virtual machines: \n{0}
    rule503_Resolution = Shut down the virtual machine and remove one or more virtual processors.
    rule503_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule504_Title      = Configure virtual machines running Windows XP Professional SP3 (x86) with 1 or 2 virtual processors
    rule504_Problem    = A virtual machine running Windows XP Professional Service Pack 3 (x86) is configured with more than 2 virtual processors.
    rule504_Impact     = Microsoft does not support the configuration of the following virtual machines: \n{0}
    rule504_Resolution = Shut down the virtual machine and remove one or more virtual processors.
    rule504_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule505_Title      = Configure virtual machines running Windows XP Professional SP2 (x64) with 1 or 2 virtual processors
    rule505_Problem    = A virtual machine running Windows XP Professional Service Pack 2 (x64) is configured with more than 2 virtual processors.
    rule505_Impact     = Microsoft does not support the configuration of the following virtual machines: \n{0}
    rule505_Resolution = Shut down the virtual machine and remove one or more virtual processors.
    rule505_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule506_Title      = Configure virtual machines running Windows 7 with no more than 4 virtual processors
    rule506_Problem    = A virtual machine running Windows 7 is configured with more than 4 virtual processors.
    rule506_Impact     = Microsoft does not support the configuration of the following virtual machines: \n{0}
    rule506_Resolution = Shut down the virtual machine and remove one or more virtual processors.
    rule506_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule508_Title      = Windows XP should be configured with at least the minimum amount of memory
    rule508_Problem    = A virtual machine running Windows XP is configured with less than 64 MB of RAM, which is the minimum amount required.
    rule508_Impact     = The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
    rule508_Resolution = Use Hyper-V Manager to increase the memory allocated to this virtual machine to at least 64 MB.
    rule508_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule509_Title      = Windows XP should be configured with the recommended amount of memory
    rule509_Problem    = A virtual machine running Windows XP is configured with less than the recommended amount of RAM, which is 128 MB.
    rule509_Impact     = The guest operating system and applications might not perform well. There might not be enough memory to run multiple applications at once. This impacts the following virtual machines:\n{0}
    rule509_Resolution = Use Hyper-V Manager to increase the memory allocated to this virtual machine to at least 128 MB.
    rule509_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule512_Title      = Windows Server 2003 should be configured with at least the minimum amount of memory
    rule512_Problem    = A virtual machine running Windows Server 2003 is configured with less than the minimum amount of RAM, which is 128 MB.
    rule512_Impact     = The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
    rule512_Resolution = Use Hyper-V Manager to increase the memory allocated to this virtual machine to at least 128 MB.
    rule512_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule513_Title      = Windows Server 2003 should be configured with the recommended amount of memory
    rule513_Problem    = A virtual machine running Windows Server 2003 is configured with less than the recommended amount of RAM, which is 256 MB.
    rule513_Impact     = The guest operating system and applications might not perform well. There might not be enough memory to run multiple applications at once. This impacts the following virtual machines:\n{0}
    rule513_Resolution = Use Hyper-V Manager to increase the memory allocated to this virtual machine to at least 256 MB.
    rule513_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule514_Title      = Windows Vista should be configured with at least the minimum amount of memory
    rule514_Problem    = A virtual machine running Windows Vista is configured with less than the minimum amount of RAM, which is 512 MB.
    rule514_Impact     = The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
    rule514_Resolution = Use Hyper-V Manager to increase the memory allocated to this virtual machine to at least 512 MB.
    rule514_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule515_Title      = Windows Vista should be configured with the recommended amount of memory
    rule515_Problem    = A virtual machine running Windows Vista is configured with less than the recommended amount of RAM, which is 1 GB.
    rule515_Impact     = The guest operating system and applications might not perform well. There might not be enough memory to run multiple applications at once. This impacts the following virtual machines:\n{0}
    rule515_Resolution = Use Hyper-V Manager to increase the memory allocated to this virtual machine to at least 1 GB.
    rule515_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule516_Title      = Windows Server 2008 should be configured with at least the minimum amount of memory
    rule516_Problem    = A virtual machine running Windows Server 2008 is configured with less than the minimum amount of RAM, which is 512 MB.
    rule516_Impact     = The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
    rule516_Resolution = Use Hyper-V Manager to increase the memory allocated to this virtual machine to at least 512 MB.
    rule516_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule517_Title      = Windows Server 2008 should be configured with the recommended amount of memory
    rule517_Problem    = A virtual machine running Windows Server 2008 is configured with less than the recommended amount of RAM, which is 2 GB.
    rule517_Impact     = The guest operating system and applications might not perform well. There might not be enough memory to run multiple applications at once. This impacts the following virtual machines:\n{0}
    rule517_Resolution = Use Hyper-V Manager to increase the memory allocated to this virtual machine to at least 2 GB.
    rule517_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule518_Title      = Windows Server 2008 R2 should be configured with at least the minimum amount of memory
    rule518_Problem    = A virtual machine running Windows Server 2008 R2 is configured with less than the minimum amount of RAM, which is 512 MB.
    rule518_Impact     = The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
    rule518_Resolution = Use Hyper-V Manager to increase the memory allocated to this virtual machine to at least 512 MB.
    rule518_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule519_Title      = Windows Server 2008 R2 should be configured with the recommended amount of memory
    rule519_Problem    = A virtual machine running Windows Server 2008 R2 is configured with less than the recommended amount of RAM, which is 2 GB.
    rule519_Impact     = The guest operating system and applications might not perform well. There might not be enough memory to run multiple applications at once. This impacts the following virtual machines:\n{0}
    rule519_Resolution = Use Hyper-V Manager to increase the memory allocated to this virtual machine to at least 2 GB.
    rule519_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule520_Title      = Windows 7 should be configured with at least the minimum amount of memory
    rule520_Problem    = A virtual machine running Windows 7 is configured with less than the minimum amount of RAM, which is 512 MB.
    rule520_Impact     = The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
    rule520_Resolution = Use Hyper-V Manager to increase the memory allocated to this virtual machine to at least 512 MB.
    rule520_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.
        
    rule521_Title      = Windows 7 should be configured with the recommended amount of memory
    rule521_Problem    = A virtual machine running Windows 7 is configured with less than the recommended amount of RAM, which is 1 GB.
    rule521_Impact     = The guest operating system and applications might not perform well. There might not be enough memory to run multiple applications at once. This impacts the following virtual machines:\n{0}
    rule521_Resolution = Use Hyper-V Manager to increase the memory allocated to this virtual machine to at least 1 GB.
    rule521_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.
        
    rule522_Title      = {1} should be configured with at least the minimum amount of memory
    rule522_Problem    = A virtual machine running {1} is configured with less than the minimum amount of RAM, which is 512 MB.
    rule522_Impact     = The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
    rule522_Resolution = Use Hyper-V Manager to increase the memory allocated to this virtual machine to at least 512 MB.
    rule522_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.
        
    rule523_Title      = {1} should be configured with the recommended amount of memory
    rule523_Problem    = A virtual machine running {1} is configured with less than the recommended amount of RAM, which is 2 GB.
    rule523_Impact     = The guest operating system and applications might not perform well. There might not be enough memory to run multiple applications at once. This impacts the following virtual machines:\n{0}
    rule523_Resolution = Use Hyper-V Manager to increase the memory allocated to this virtual machine to at least 2 GB.
    rule523_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.
        
    rule524_Title      = {1} should be configured with at least the minimum amount of memory
    rule524_Problem    = A virtual machine running {1} is configured with less than the minimum amount of RAM, which is 512 MB.
    rule524_Impact     = The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
    rule524_Resolution = Use Hyper-V Manager to increase the memory allocated to this virtual machine to at least 512 MB.
    rule524_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.
        
    rule525_Title      = {1} should be configured with the recommended amount of memory
    rule525_Problem    = A virtual machine running {1} is configured with less than the recommended amount of RAM, which is 1 GB.
    rule525_Impact     = The guest operating system and applications might not perform well. There might not be enough memory to run multiple applications at once. This impacts the following virtual machines:\n{0}
    rule525_Resolution = Use Hyper-V Manager to increase the memory allocated to this virtual machine to at least 1 GB.
    rule525_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule576_Title      = Avoid using snapshots on a virtual machine that runs a server workload in a production environment
    rule576_Problem    = A virtual machine with one or more snapshots has been found.
    rule576_Impact     = Available space may run out on the physical disk that stores the snapshot files. If this occurs, no additional disk operations can be performed on the physical storage. Any virtual machine that relies on the physical storage could be affected.
    rule576_Resolution = If the virtual machine runs a server workload in a production environment, take the virtual machine offline and then use Hyper-V Manager to apply or delete the snapshots. To delete snapshots, you must shut down the virtual machine to complete the process.
    rule576_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.
        
    rule600_Title      = Configure a virtual machine with a SCSI controller to be able to hot plug and hot unplug storage
    rule600_Problem    = A virtual machine was found that is not configured with a SCSI controller.
    rule600_Impact     = You will not be able to hot plug or hot unplug storage for the following virtual machines:\n{0}
    rule600_Resolution = If you do not need to hot plug or hot unplug storage for this virtual machine, no action is required. Otherwise, shut down the virtual machine and add a SCSI controller to the configuration.
    rule600_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule601_Title      = Configure SCSI controllers only when supported by the guest operating system
    rule601_Problem    = A virtual machine is configured with a SCSI controller that cannot be used because the guest operating system does not support SCSI controllers.
    rule601_Impact     = Virtual machines cannot use storage attached to the SCSI controller. This impacts the following virtual machines:\n{0}
    rule601_Resolution = Shut down the virtual machine and use Hyper-V Manager to remove the SCSI controller from the virtual machine. Then, restart the virtual machine.
    rule601_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule602_Title      = Avoid configuring virtual machines to allow unfiltered SCSI commands
    rule602_Problem    = A virtual machine is configured to allow unfiltered SCSI commands.
    rule602_Impact     = Bypassing SCSI command filtering poses a security risk. This configuration should be enabled only if it is required for compatibility with storage applications running in the guest operating system. The following virtual machines are configured to allow unfiltered SCSI commands:\n{0}
    rule602_Resolution = Contact your storage vendor to determine if this configuration is required. Also, if the management operating system or other guest operating systems are compromised or exhibit unusual behavior, reconfigure the virtual machine to block the commands.
    rule602_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule604_Title      = Avoid using virtual hard disks with a sector size less than the sector size of the physical storage that stores the virtual hard disk file
    rule604_Problem    = One or more virtual hard disks have a physical sector size that is smaller than the physical sector size of the storage on which the virtual hard disk file is located.
    rule604_Impact     = Performance problems might occur on the virtual machine or application that use the virtual hard disk. This impacts the following virtual machines:\n{0}
    rule604_Resolution = Do one of the following: Perform a storage migration to move the virtual hard disk to a new physical system, use Windows PowerShell or WMI to enable a VHDX-format virtual hard disk to report a specific sector size, or use a registry setting to enable a VHD-format virtual hard disk to report a physical sector size of 4k.
    rule604_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule650_Title      = Avoid configuring a child storage resource pool when the directory path of the child is not a subdirectory of the parent
    rule650_Problem    = A storage resource pool is not configured correctly on this host because a child resource pool uses a directory that is not a subdirectory of the parent resource pool.
    rule650_Impact     = For the specified storage pool type, the following parent and child pools share the same storage path:\n{0}
    rule650_Resolution = Use Windows PowerShell to reconfigure how the storage file paths are allocated to the pool so that a child pool is always allocated from a subdirectory of a parent pool.
    rule650_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    rule652_Title      = Avoid mapping one storage path to multiple resource pools.
    rule652_Problem    = A storage file path is mapped to multiple resource pools.
    rule652_Impact     = For the specified storage pool type, the following parent and child pools share the same storage path:\n{0}
    rule652_Resolution = Use Windows PowerShell to reconfigure the storage resource pools so that multiple pools do not use the same storage path.
    rule652_Compliant  = The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

###PSLOC - End Localization
'@
}
Import-LocalizedData -BindingVariable _system_translations -fileName Hyper-V.psd1

#
# -------------
# CONSTANTS
# -------------
#

# Platform limits
$MAX_LOGICAL_PROCESSORS = 160
$MAX_CONFIGURED_VMS = 1024
$MAC_RANGE = 20

# WMI constants
$RUNNING = 2
$PAUSED = 9
$HEALTH_OK = 5
$HVR_MODE_PRIMARY = 1
$HVR_MODE_RECOVERY = 2
$HVR_STATE_DISABLED = 0
$HVR_STATE_WAITINGFORIRCOMPLETE = 2
$HVR_STATE_RECOVERYRECOVERED = 5
$HVR_STATE_PAUSED = 7
$RESOURCE_TYPE_OTHER = 1

$STORAGE_FORMAT_VHD = 2
$STORAGE_FORMAT_VHDX = 3

$V2_NS = "root\virtualization\v2"
$CLUSTER_NS = "root\MSCluster"

# VMMS Error codes
$S_OK = 0
$VM_E_FR_CC_INCONSISTENCIES_DETECTED = [UInt32]"0x800480D1"

#
# ----------------
# HELPER FUNCTIONS
# ----------------
#

# Always have Client followed by corresponding Server in
# OSTYPE.
$OSTYPE_NONE = 0
$OSTYPE_XP = 1
$OSTYPE_SERVER_2003 = 2
$OSTYPE_VISTA = 3
$OSTYPE_SERVER_2008 = 4
$OSTYPE_7 = 5
$OSTYPE_SERVER_2008_R2 = 6
$OSTYPE_VERSION_6POINT2 = 7
$OSTYPE_SERVER_VERSION_6POINT2 = 8

function GetOsType($Kvp)
#
# FUNCTION DESCRIPTION:
#   Determines OSTYPE based on kvp hash.
# 
# PARAMETERS:
#   $Kvp - The hash of kvp values for a VM returned by GetKvpHashFromXml
#
# RETURN VALUES:
#   $osType - The type of the OS from the "enum" variables defined globally.
#
{
    $osType = $OSTYPE_NONE
    if ($Kvp.guestintrinsic)
    {
        if ($Kvp.guestintrinsic.OSVersion -like "5.1*" -or
            $Kvp.guestintrinsic.OSVersion -like "5.2*")
        {
            $osType = $OSTYPE_XP
        }
        elseif ($Kvp.guestintrinsic.OSVersion -like "6.0*")
        {
            $osType = $OSTYPE_VISTA
        }
        elseif ($Kvp.guestintrinsic.OSVersion -like "6.1*")
        {
            $osType = $OSTYPE_7
        }
        elseif ($Kvp.guestintrinsic.OSVersion -like "6.2*")
        {
            $osType = $OSTYPE_VERSION_6POINT2
        }
        
        if ($osType -ne $OSTYPE_NONE -and 
            [int]$Kvp.guestintrinsic.ProductType -ne 1)
        {
            $osType++
        }
    }
    
    return $osType
}

function PopulateWmiCache()
#
# FUNCTION DESCRIPTION:
#   Populates the global wmi cache with interesting WMI class instances
# 
# PARAMETERS:
#   None.
#
# RETURN VALUES:
#   None.
#
{
  $global:cache = @{}
  
  # VM Settings
  $cache.Msvm_ComputerSystem =
    gwmi -n $V2_NS Msvm_ComputerSystem
  $cache.Msvm_MemorySettingData = 
    gwmi -n $V2_NS Msvm_MemorySettingData
  $cache.Msvm_Processor = 
    gwmi -n $V2_NS Msvm_Processor
  $cache.Msvm_VirtualSystemSettingData =
    gwmi -n $V2_NS Msvm_VirtualSystemSettingData
  $cache.Msvm_Synthetic3DDisplayControllerSettingData =
    gwmi -n $V2_NS Msvm_Synthetic3DDisplayControllerSettingData  

  # VM Replication settings
  $cache.Msvm_ReplicationSettingData =
    gwmi -n $V2_NS Msvm_ReplicationSettingData

  # Host-level settings
  $cache.Msvm_VirtualSystemManagementService =
    gwmi -n $V2_NS Msvm_VirtualSystemManagementService
  $cache.Msvm_VirtualSystemManagementServiceSettingData = 
    gwmi -n $V2_NS Msvm_VirtualSystemManagementServiceSettingData
  $cache.Msvm_MetricServiceSettingData =
    gwmi -n $V2_NS Msvm_MetricServiceSettingData
  $cache.Msvm_VirtualSystemMigrationService =
    gwmi -n $V2_NS Msvm_VirtualSystemMigrationService
  $cache.Msvm_VirtualSystemMigrationServiceSettingData =
    gwmi -n $V2_NS Msvm_VirtualSystemMigrationServiceSettingData
  $cache.Msvm_VirtualEthernetSwitchManagementCapabilities =
    gwmi -n $V2_NS Msvm_VirtualEthernetSwitchManagementCapabilities
  $cache.Msvm_ResourceAllocationFromPool = 
    gwmi -n $V2_NS Msvm_ResourceAllocationFromPool
    
  # Failover Replication service
  $cache.Msvm_ReplicationService = 
    gwmi -n $V2_NS Msvm_ReplicationService
  $cache.Msvm_ReplicationServiceSettingData = 
    gwmi -n $V2_NS Msvm_ReplicationServiceSettingData
  if ($cache.Msvm_ReplicationService -ne $null)
  {
    $cache.Msvm_ReplicationAuthorizationSettingData = 
      @($cache.Msvm_ReplicationService.GetRelated("Msvm_ReplicationAuthorizationSettingData"))
  }
  $cache.FRBR_MSCluster_Resource = 
    gwmi -n $CLUSTER_NS -q "SELECT * FROM MSCluster_Resource WHERE Type='Virtual Machine Replication Broker'" -ea SilentlyContinue
     
  # Storage
  $cache.Msvm_ImageManagementService =
    gwmi -n $V2_NS Msvm_ImageManagementService    
  $cache.Msvm_ScsiProtocolController = 
    gwmi -n $V2_NS Msvm_ScsiProtocolController
  $cache.Msvm_StorageAllocationSettingData =
    gwmi -n $V2_NS Msvm_StorageAllocationSettingData `
      -filter "ResourceSubType='Microsoft:Hyper-V:Virtual Hard Disk'" | `
      ?{$_.HostResource -ne $null -and (($_.HostResource[0] -match ".*[.]a*vhd") -or ($_.HostResource[0] -match ".*[.]a*vhdx"))}
  $cache.Msvm_FCPortAllocationSettingData =
    gwmi -n $V2_NS Msvm_FCPortAllocationSettingData
  $cache.Msvm_FcActiveConnection =
    gwmi -n $V2_NS Msvm_FcActiveConnection
  $cache.Msvm_ExternalFCPort =
    gwmi -n $V2_NS Msvm_ExternalFCPort
    
  # Networking
  $cache.Msvm_EmulatedEthernetPortSettingData =
    gwmi -n $V2_NS Msvm_EmulatedEthernetPortSettingData
  $cache.Msvm_VirtualEthernetSwitch =
    gwmi -n $V2_NS Msvm_VirtualEthernetSwitch
  $cache.Msvm_ExternalEthernetPort =
    gwmi -n $V2_NS Msvm_ExternalEthernetPort
  $cache.Msvm_InternalEthernetPort =
    gwmi -n $V2_NS Msvm_InternalEthernetPort
  $cache.Msvm_EthernetPortAllocationSettingData =
    gwmi -n $V2_NS Msvm_EthernetPortAllocationSettingData
  $cache.Msvm_EthernetSwitchPortOffloadSettingData =
    gwmi -n $V2_NS Msvm_EthernetSwitchPortOffloadSettingData
  $cache.Msvm_EthernetSwitchPort =
    gwmi -n $V2_NS Msvm_EthernetSwitchPort
  $cache.Msvm_EthernetSwitchPortOffloadData =
    gwmi -n $V2_NS Msvm_EthernetSwitchPortOffloadData
  $cache.Msvm_ActiveConnection =
    gwmi -n $V2_NS Msvm_ActiveConnection
  $cache.Msvm_ExternalEthernetPortCapabilities =
    gwmi -n $V2_NS Msvm_ExternalEthernetPortCapabilities
  $cache.Msvm_LanEndPoint =
    gwmi -n $V2_NS Msvm_LanEndPoint
  $cache.Msvm_FailoverNetworkAdapterSettingData =
    gwmi -n $V2_NS Msvm_FailoverNetworkAdapterSettingData
  $cache.Msvm_EthernetSwitchPortSecuritySettingData =
    gwmi -n $V2_NS Msvm_EthernetSwitchPortSecuritySettingData
  $cache.Msvm_EthernetSwitchPortVlanSettingData =
    gwmi -n $V2_NS Msvm_EthernetSwitchPortVlanSettingData
  $cache.Msvm_EthernetSwitchExtension =
    gwmi -n $V2_NS Msvm_EthernetSwitchExtension
   $cache.MSFT_NetAdapterVmqSettingData =
    gwmi -n root\standardcimv2 MSFT_NetAdapterVmqSettingData
  $cache.MSFT_NetLbfoTeamNic =
    gwmi -n root\standardcimv2 MSFT_NetLbfoTeamNic
  $cache.MSFT_NetAdapter =
    gwmi -n root\standardcimv2 MSFT_NetAdapter

  # Networking switch extensions
  $cache.Msvm_VirtualEthernetSwitchSettingData =
    gwmi -n $V2_NS Msvm_VirtualEthernetSwitchSettingData
  $cache.Msvm_EthernetSwitchHardwareOffloadData =
    gwmi -n $V2_NS Msvm_EthernetSwitchHardwareOffloadData

  # An association map, mapping a switch to another associative map,
  # mapping a enabled/installed extension pathname to a boolean value
  # ($true). This can be used to efficiently determine if a specific
  # switch extension is enabled/installed for a specific switch.
  $cache.Msvm_InstalledVirtualSwitchExtensionsMap = @{}
                                                                        
  # Enumerate all virtual switches...
  foreach ($virtualSwitch in $cache.Msvm_VirtualEthernetSwitch)
  {
    $switchFeatureCapabilityMap = @{}

    $parentVirtualSwitchExtensions =
      @($virtualSwitch.GetRelated("Msvm_EthernetSwitchExtension"))

    $allVirtualSwitchExtensions = @($parentVirtualSwitchExtensions)

    foreach ($parentVirtualSwitchExtension in $parentVirtualSwitchExtensions)
    {
       # Get the child extensions, if any. Child extensions are only one level deep.
       $allVirtualSwitchExtensions +=
         @($parentVirtualSwitchExtension.GetRelated("Msvm_EthernetSwitchExtension"))
    }

    foreach ($virtualSwitchExtension in $allVirtualSwitchExtensions)
    {
      # Enumerated enabled and installed switch extensions.
      if (($virtualSwitchExtension.EnabledState -eq 2) -or # Enabled
          ($virtualSwitchExtension.EnabledState -eq 5))    # Not Applicable
      {
        $installedVirtualSwitchExtensions =
          @($virtualSwitchExtension.GetRelated("Msvm_InstalledEthernetSwitchExtension"))

        foreach ($installedVirtualSwitchExtension in $installedVirtualSwitchExtensions)
        {
          $switchFeatureCapabilities =
            @($installedVirtualSwitchExtension.GetRelated("Msvm_EthernetSwitchFeatureCapabilities"))

          foreach ($switchFeatureCapability in $switchFeatureCapabilities)
          {
              $switchFeatureCapabilityMap.Add($switchFeatureCapability.__PATH,
                                              $true)
          }
        }
      }
    }

    $cache.Msvm_InstalledVirtualSwitchExtensionsMap.Add($virtualSwitch, 
                                                        $switchFeatureCapabilityMap)
  }
    
  # Synthetic Devices
  $cache.Msvm_SyntheticDisplayController = 
    gwmi -n $V2_NS Msvm_SyntheticDisplayController
  $cache.Msvm_Synth3dVideoPool =
    gwmi -n $V2_NS Msvm_Synth3dVideoPool
    
  # Integration Components
  $cache.Msvm_ShutdownComponent =
    gwmi -n $V2_NS Msvm_ShutdownComponent
  $cache.Msvm_ShutdownComponentSettingData =
    gwmi -n $V2_NS Msvm_ShutdownComponentSettingData
  $cache.Msvm_TimeSyncComponent =
    gwmi -n $V2_NS Msvm_TimeSyncComponent
  $cache.Msvm_TimeSyncComponentSettingData =
    gwmi -n $V2_NS Msvm_TimeSyncComponentSettingData
  $cache.Msvm_HeartbeatComponent =
    gwmi -n $V2_NS Msvm_HeartbeatComponent
  $cache.Msvm_HeartbeatComponentSettingData =
    gwmi -n $V2_NS Msvm_HeartbeatComponentSettingData
  $cache.Msvm_VssComponent =
    gwmi -n $V2_NS Msvm_VssComponent
  $cache.Msvm_VssComponentSettingData =
    gwmi -n $V2_NS Msvm_VssComponentSettingData
  $cache.Msvm_KvpExchangeComponent =
    gwmi -n $V2_NS Msvm_KvpExchangeComponent
  $cache.Msvm_KvpExchangeComponentSettingData =
    gwmi -n $V2_NS Msvm_KvpExchangeComponentSettingData
    
  # Win32 objects
  $cache.Win32_NetworkAdapterConfiguration =
    gwmi -n root\cimv2 Win32_NetworkAdapterConfiguration
  $cache.Win32_NetworkAdapter =
    gwmi -n root\cimv2 Win32_NetworkAdapter
    
  # An association map matching switches to their external ports
  $cache.SwitchToExternalPortMap = @{}

  foreach ($externalPort in $cache.Msvm_ExternalEthernetPort)
  {
    $virtualSwitch = (GetVirtualSwitchFromNicPort $externalPort)
    if ($virtualSwitch -ne $null)
    {
      $cache.SwitchToExternalPortMap.Add($virtualSwitch.Name, $externalPort)
    }
  }
  
  # List of physical NIC adapters which the migration service is actively listening on
  # for incoming migration requests
  $win32ListeningNicList = GetMigrationListenerWin32Nics
  $cache.MigrationPhysicalListeningNicList = (ResolveToPhysicalNics $win32ListeningNicList)

  # CRM related objects.

  # An association map, mapping resource pools of a
  # given type to the resource sub type or other resource type.
  $cache.Msvm_ResourcePoolMap = @{}

  $allPools = @(gwmi -n $V2_NS Msvm_ResourcePool)

  $primordialPools = @($allPools | ?{($_.Primordial)})

  foreach($primordialPool in $primordialPools)
  {
    $resourceType = ""
  
    if ($primordialPool.ResourceType -eq $RESOURCE_TYPE_OTHER)
    {
      $resourceType = $primordialPool.OtherResourceType
  
      $pools = @($allPools |
                 ?{($_.ResourceType      -eq $primordialPool.ResourceType) -and 
                   ($_.OtherResourceType -eq $primordialPool.OtherResourceType)})
    }
    else
    {
      $resourceType = $primordialPool.ResourceSubType
  
      $pools = @($allPools |
                 ?{($_.ResourceType    -eq $primordialPool.ResourceType) -and 
                   ($_.ResourceSubType -eq $primordialPool.ResourceSubType)})
    }
  
    $cache.Msvm_ResourcePoolMap.Add($resourceType, $pools)
  }
}

function InsertIntoHashCache($wmiClassName, $propertyName, $startIndex)
{
  # Can be further improved to use gwmi and 
  # eliminate the need for $cache and saving the 
  # memory overhead for some classes
  foreach ($wmiObject in $cache.Item($wmiClassName))
  {
    # Extract VM Guid
    # TODO: This can be made even more flexible by
    # passing the property name as an argument. 
    $guid = $wmiObject.Item($propertyName)
    if ($guid.length -lt (36 + $startIndex))
    {
      continue
    }
    $vmGuid = $guid.substring($startIndex, 36).ToUpper()
    
    # Make sure that it's a valid Guid
    if ($vmCache[$vmGuid] -ne $null)
    {
      if ($vmCache[$vmGuid][$wmiClassName] -eq $null)
      {
        $vmCache[$vmGuid][$wmiClassName] = @()
      }
      $vmCache[$vmGuid][$wmiClassName] += $wmiObject
    }
  }
}

function CreateHashCache()
{
  $global:vmCache = @{}
  
  if ($cache.Msvm_VirtualSystemManagementService -eq $null)
  {
    return
  }

  # Creating hash-based VM Cache
  $vms = @($cache.Msvm_VirtualSystemManagementService.GetRelated("Msvm_ComputerSystem",
                                                      "Msvm_ServiceAffectsElement",
                                                      $null,
                                                      $null,
                                                      $null,
                                                      $null,
                                                      $false,
                                                      $null));

  $vms | %{$vmCache[$_.Name.ToUpper()] = @{}}
   
  InsertIntoHashCache "Msvm_ComputerSystem" "Name" 0

  # For SettingData classes, the InstanceId Format is "Microsoft:VmGuid/ObjectGuid".
  $InstanceId = "InstanceId"
  InsertIntoHashCache "Msvm_MemorySettingData" $InstanceId 10
  InsertIntoHashCache "Msvm_Synthetic3DDisplayControllerSettingData" $InstanceId 10
  InsertIntoHashCache "Msvm_StorageAllocationSettingData" $InstanceId 10
  InsertIntoHashCache "Msvm_EmulatedEthernetPortSettingData" $InstanceId 10
  InsertIntoHashCache "Msvm_ShutdownComponentSettingData" $InstanceId 10
  InsertIntoHashCache "Msvm_TimeSyncComponentSettingData" $InstanceId 10
  InsertIntoHashCache "Msvm_HeartbeatComponentSettingData" $InstanceId 10
  InsertIntoHashCache "Msvm_VssComponentSettingData" $InstanceId 10
  InsertIntoHashCache "Msvm_KvpExchangeComponentSettingData" $InstanceId 10
  InsertIntoHashCache "Msvm_ReplicationSettingData" $InstanceId 10
  InsertIntoHashCache "Msvm_FCPortAllocationSettingData" $InstanceId 10
  InsertIntoHashCache "Msvm_EthernetPortAllocationSettingData" $InstanceId 10
  InsertIntoHashCache "Msvm_SyntheticEthernetPortSettingData" $InstanceId 10
  #For FailoverNetworkAdapterSettingData, InstanceID format is "Microsoft:FailoverNetworkSetting\VmGuid\ObjectGuid".
  InsertIntoHashCache "Msvm_FailoverNetworkAdapterSettingData" $InstanceId 33
  InsertIntoHashCache "Msvm_EthernetSwitchPortSecuritySettingData" $instanceId 10
  
  # In Logical devices, the VM Guid can be found in SystemName property.
  $SystemName = "SystemName"
  InsertIntoHashCache "Msvm_Processor" $SystemName 0
  InsertIntoHashCache "Msvm_ScsiProtocolController" $SystemName 0
  InsertIntoHashCache "Msvm_LanEndPoint" $SystemName 0
  InsertIntoHashCache "Msvm_SyntheticDisplayController" $SystemName 0
  InsertIntoHashCache "Msvm_ShutdownComponent" $SystemName 0
  InsertIntoHashCache "Msvm_TimeSyncComponent" $SystemName 0
  InsertIntoHashCache "Msvm_HeartbeatComponent" $SystemName 0
  InsertIntoHashCache "Msvm_VssComponent" $SystemName 0
  InsertIntoHashCache "Msvm_KvpExchangeComponent" $SystemName 0
  
  # Using VirtualSystemIdentifier for Msvm_VirtualSystemSettingData
  # so that the snapshots are included as well
  InsertIntoHashCache "Msvm_VirtualSystemSettingData" "VirtualSystemIdentifier" 0
  
}
function GetKvpHashFromXml($Kvp)
#
# FUNCTION DESCRIPTION:
#   Returns a well-formed hash table of KVP data given a KVP XML blob
# 
# PARAMETERS:
#   $Kvp - the KVP xml blob
#
# RETURN VALUES:
#   $KvpHash - The well-formed hash table of KVP data
#
{
  $KvpHash = @{}
  if($Kvp -ne $null)
  {
    ([xml]("<xml>" + $Kvp + "</xml>")).xml.instance | `
      foreach `
      {
        # Property 5 is the key and property 1 is the value
        $KvpHash.add($_.property[5].value, $_.property[1].value)
      }
  }
    
  $KvpHash
}


function GetVirtualSwitchFromNicPort($Port)
#
# FUNCTION DESCRIPTION:
#   Returns the virtual switch which the given NIC port is attached to, if any.
# 
# PARAMETERS:
#   $Port - a Msvm_InternalEthernetPort or Msvm_ExternalEthernetPort object
#
# RETURN VALUES:
#   $virtualSwitch - The switch the given $Port is connected to, $null if none.
#
{
  foreach ($vswitch in $cache.Msvm_VirtualEthernetSwitch)
  {
    if ($cache.Msvm_ActiveConnection | `
      ?{$_.Antecedent -like "*$($vswitch.Name)*" -and 
      $_.Dependent -like "*$($Port.DeviceID)*"})
    {
      $vswitch
    }
  }  
}


function GetPortsFromVirtualSwitch($VirtualSwitch, $PortType)
#
# FUNCTION DESCRIPTION:
#   Returns an array of ports of the specified type attached to the specified
#   virtual switch.
# 
# PARAMETERS:
#   $VirtualSwitch - the virtual switch whose ports will be retrieved
#
#   $PortType - can be "Msvm_InternalEthernetPort" or "Msvm_ExternalEthernetPort"
#
# RETURN VALUES:
#   $ports - The array of mapped ports of the given type
#
{
  foreach ($port in $cache.Item($PortType))
  {
    if ($cache.Msvm_ActiveConnection | `
      ?{$_.Antecedent -like "*$($VirtualSwitch.Name)*" -and 
      $_.Dependent -like "*$($port.DeviceID)*"})
    {
      $port
    }
  }
}

function GetFCPortsFromVirtualFCSwitch($VirtualFCSwitch, $FCPortType)
#
# FUNCTION DESCRIPTION:
#   Returns an array of ports of the specified type attached to the specified
#   virtual switch.
# 
# PARAMETERS:
#   $VirtualFCSwitch - the virtual switch whose ports will be retrieved
#
#   $PortType - can be "Msvm_FCSwitchPort" or "Msvm_ExternalFCPort"
#
# RETURN VALUES:
#   $ports - The array of mapped ports of the given type
#
{
  foreach ($port in $cache.Item($FCPortType))
  {
    if ($cache.Msvm_FcActiveConnection | `
      ?{$_.Antecedent -like "*$($VirtualFCSwitch.Name)*" -and 
      $_.Dependent -like "*$($port.DeviceID)*"})
    {
      $port
    }
  }
}

function GetInternalPortsFromExternalPort($ExternalPort)
#
# FUNCTION DESCRIPTION:
#   Returns an array of internal ports attached to the switch the external
#   port is attached to.
# 
# PARAMETERS:
#   $ExternalPort - the external port to trace
#
# RETURN VALUES:
#   $internalPorts - The array of mapped internal ports
#
{
  # Get the switch for the external port
  $virtualSwitch = (GetVirtualSwitchFromNicPort $ExternalPort)
  if ($virtualSwitch -eq $null)
  {
    return $null
  }
  
  # Get all internal ports
  $internalPorts = (GetPortsFromVirtualSwitch $virtualSwitch "Msvm_InternalEthernetPort")

  $internalPorts
}

function GetMacAddressRangeSize
#
# FUNCTION DESCRIPTION:
#   Determines the size of the range of MAC addresses able to be assigned to virtual
#   NICs
# 
# PARAMETERS:
#   None.
#
# RETURN VALUES:
#   [unnamed integer] The range size
#
{
  if ($cache.Msvm_VirtualSystemManagementServiceSettingData -eq $null)
  {
    $null
    return
  }
  
  $max = $cache.Msvm_VirtualSystemManagementServiceSettingData.MaximumMacAddress
  $min = $cache.Msvm_VirtualSystemManagementServiceSettingData.MinimumMacAddress
  
  $index = $max.length
  while ($max.substring(0, $index) -ne $min.substring(0, $index))
  {
    $index--
  }
  
  $max = [uint64]("0x" + $max.substring($index, $max.length - $index))
  $min = [uint64]("0x" + $min.substring($index, $min.length - $index))
  
  ($max-$min)+1
}


function GetAllowedConcurrentMigrationCount
#
# FUNCTION DESCRIPTION:
#   Determines the number of allowed concurrent virtual machine migrations
# 
# PARAMETERS:
#   None.
#
# RETURN VALUES:
#   $count - The allowed count
#
{
  $count = 0
  
  if ($cache.Msvm_VirtualSystemMigrationServiceSettingData.AllowInboundVirtualSystemMigration)
  {
    $count = $cache.Msvm_VirtualSystemMigrationServiceSettingData.MaximumActiveVirtualSystemMigration
  }
  
  $count
}


function GetMigrationListenerIPAddresses
#
# FUNCTION DESCRIPTION:
#   Determines the array of IP addresses the host is listening on for incoming migration
#   requests.
# 
# PARAMETERS:
#   None.
#
# RETURN VALUES:
#   $ipList - The array of IP address (in both IPv4 & IPv6 formats)
#
{
  $ipList = @()

  if ($cache.Msvm_VirtualSystemMigrationServiceSettingData.AllowInboundVirtualSystemMigration)
  {
    $ipList = $cache.Msvm_VirtualSystemMigrationService.MigrationServiceListenerIPAddressList
  }
  
  $ipList
}


function GetMigrationListenerWin32Nics
#
# FUNCTION DESCRIPTION:
#   Determines the set of Win32 NIC objects which are configured to listen for incoming
#   migration requests.
# 
# PARAMETERS:
#   None.
#
# RETURN VALUES:
#   $win32ListeningNicList - The list of Win32_NetworkAdapter NIC objects
#
{
  $win32ListeningNicList = @()
  
  $listenerIpList = GetMigrationListenerIPAddresses

  foreach ($ipAddress in $listenerIpList)
  {
    foreach ($nicConfig in $cache.Win32_NetworkAdapterConfiguration)
    {
      if($nicConfig.IPAddress -contains $ipAddress)
      {
        $win32Nic = @($cache.Win32_NetworkAdapter | ?{($_.GUID) -eq $nicConfig.SettingID})[0]
        $win32ListeningNicList += $win32Nic
      }
    }
  }

  # Ensure only unique entries remain in the array
  $win32ListeningNicList = $win32ListeningNicList | Get-Unique
  
  $win32ListeningNicList
}


function ResolveToPhysicalNics($Win32NicList)
#
# FUNCTION DESCRIPTION:
#   Returns the list of physical NICs which the given list of NICs are attached
#   to for real network traffic.  Any physical NICs in the given list are passed through
#   while the virtual NICs in the given list are mapped through their connected virtual
#   switches to external physical NICs.
# 
# PARAMETERS:
#   $Win32NicList - List of Win32_NetworkAdapters to be resolved.
#
# RETURN VALUES:
#   $physicalNicList - List of resolved Win32_NetworkAdapters.
#
{
  $physicalNicList = @()

  foreach ($win32Nic in $Win32NicList)
  {
    # Attempt to find an internal port for this win32 NIC
    $internalPort = $cache.Msvm_InternalEthernetPort | ?{$_.DeviceID -eq 'Microsoft:'+$win32Nic.GUID}

    if ($internalPort -eq $null)
    {
      # This is a physical adapter, add it directly
      $physicalNicList += $win32Nic
      continue;
    }

    # This is a virtual adapter connected to a virtual switch.  Find the physical
    # adapter connected to the virtual switch, if any.
    
    $virtualSwitch = (GetVirtualSwitchFromNicPort $internalPort)
    if ($virtualSwitch -eq $null)
    {
      # No virtual switch for this port
      continue;
    }

    $externalPort = $cache.SwitchToExternalPortMap[$virtualSwitch.Name]
    if ($externalPort -eq $null)
    {
      # No external port for this switch
      continue;
    }
    
    $deviceId = ($externalPort.DeviceID).Split(':')[1]
    $physicalNic = $cache.Win32_NetworkAdapter | ?{$_.GUID -eq $deviceId}

    if ($physicalNic -eq $null)
    {
      # No matching physical NIC for this external port.  This shouldn't happen.
      continue;
    }

    $physicalNicList += $physicalNic
  }

  # Ensure only unique entries remain in the array
  $physicalNicList = $physicalNicList | Get-Unique
  
  $physicalNicList
}


function GetMigrationListenerPhysicalNics
#
# FUNCTION DESCRIPTION:
#   Determines the set of Win32 NIC objects representing physical network adapters 
#   which are configured to listen for incoming migration requests.
# 
# PARAMETERS:
#   None.
#
# RETURN VALUES:
#   $physicalListeningNicList - The list of Win32_NetworkAdapter NIC objects
#
{
  $win32ListeningNicList = GetMigrationListenerWin32Nics
  
  $physicalListeningNicList = (ResolveToPhysicalNics $win32ListeningNicList)
  
  $physicalListeningNicList
}


function GetMetricsFlushInterval
#
# FUNCTION DESCRIPTION:
#   Retrieves the metrics flush interval. This indicates how frequently metric values
#   are automatically saved to disk.
# 
# PARAMETERS:
#   None.
#
# RETURN VALUES:
#   [Timespan] The metrics flush interval.
#
{
  $metricsFlushIntervalDmtf = $cache.Msvm_MetricServiceSettingData.MetricsFlushInterval
  
  $metricsFlushInterval = [system.management.managementdatetimeconverter]::ToTimeSpan($metricsFlushIntervalDmtf)
  
  $metricsFlushInterval
}


function VerifyStoragePathsStrictSubsetRecursive($ParentPool)
#
# FUNCTION DESCRIPTION:
#   Verify that the paths assigned to a child pool are a subdirectory
#   of the parent pool paths. This is a recursive function.
# 
# PARAMETERS:
#   ParentPool - the storage pool to verify.
#
# RETURN VALUES:
#   A string containing a newline seperated list of
#   pool Id related information for pools that failed the
#   verification.
#
{
  $resultString = ""

  $parentPoolAssignmentRasd = @()
  $parentPoolAssignedResources = @()

  # The parent pool does not have a Msvm_SettingDefineState RASD. By
  # definition, the primordial pool is assigned all host resources.
  if (-not $ParentPool.Primordial)
  {
    $parentPoolAssignedResources =
      @($ParentPool.GetRelated("Msvm_ResourceAllocationSettingData",
                               "Msvm_SettingsDefineState",
                               $null,
                               $null,
                               $null,
                               $null,
                               $false,
                               $null) | %{$_.HostResource})
  }

  # Get the child pools decended from this pool.
  $childPools =
    @($ParentPool.GetRelated("Msvm_ResourcePool",
                             "Msvm_ElementAllocatedFromPool",
                             $null,
                             $null,
                             "Dependent",
                             "Antecedent",
                             $false,
                             $null))

  foreach ($childPool in $childPools)
  {
    $childPoolAssignedResources =
      @($childPool.GetRelated("Msvm_ResourceAllocationSettingData",
                              "Msvm_SettingsDefineState",
                              $null,
                              $null,
                              $null,
                              $null,
                              $false,
                              $null) | %{$_.HostResource})

    # For each child resource, make sure it is a strict subset of the
    # cooresponding parent assignment.
    foreach ($childPoolAssignedResource in $childPoolAssignedResources)
    {
      foreach ($parentPoolAssignedResource in $parentPoolAssignedResources)
      {
        if ($childPoolAssignedResource -ieq $parentPoolAssignedResource)
        {
           $resultString +=
              "`t" + $ParentPool.PoolId + " / " +
              $childPool.PoolId + " (" + $childPool.InstanceID + ")`n"
        }
      }
    }

    # Call recursively for all child pools.
    $resultString += (VerifyStoragePathsStrictSubsetRecursive $childPool)
  }

  $resultString
}


function VerifyStoragePathsStrictSubset($ResourceSubType)
#
# FUNCTION DESCRIPTION:
#   Verify that the paths assigned to a child pool are a subdirectory
#   of the parent pool paths.
# 
# PARAMETERS:
#   ResourceSubType - the ResourceStorageSubType of the type of
#      storage file pool to verify.
#
# RETURN VALUES:
#   A string containing a newline seperated list of
#   pool Id related information for pools that failed the
#   verification.
#
{
  $resultString = ""

  $primordialPool =
    @($cache.Msvm_ResourcePoolMap[$ResourceSubType] |
      ?{($_.Primordial)})[0]

  if ($primordialPool -ne $null)
  {
    # Get the primordial pool's child pools.
    $childPools =
        @($primordialPool.GetRelated("Msvm_ResourcePool",
                                     "Msvm_ElementAllocatedFromPool",
                                     $null,
                                     $null,
                                     "Dependent",
                                     "Antecedent",
                                     $false,
                                     $null))
  }

  foreach ($childPool in $childPools)
  {
    # For each child pool, verify the storage paths of it's descendents.
    $resultString += (VerifyStoragePathsStrictSubsetRecursive $childPool)
  }

  $resultString
}


function VerifyStoragePathOnlyInOnePoolRecursive($ParentPool, $PathNameMap)
#
# FUNCTION DESCRIPTION:
#   This function verified that a storage file path is assigned
#     to a single storage pool. This is a recursive function.
# 
# PARAMETERS:
#   ParentPool - the storage pool to verify.
# 
#   PathNameMap - reference to an association map
#     mapping a storage file path to the instance id
#     of the first pool found to have it assigned.
#
# RETURN VALUES:
#   A string containing a newline seperated list of
#   pool Id related information for paths that failed the
#   verification.
#
{
  $resultString = ""

  $parentPoolAssignmentRasd = @()
  $parentPoolAssignedResources = @()

  # The parent pool does not have a Msvm_SettingDefineState RASD. By
  # definition, the primordial pool is assigned all host resources.
  if (-not $ParentPool.Primordial)
  {
    # Parent RASD representing parent pool assignments. There is
    # one per child pool.
    $parentPoolAssignedResources =
      @($ParentPool.GetRelated("Msvm_ResourceAllocationSettingData",
                               "Msvm_SettingsDefineState",
                               $null,
                               $null,
                               $null,
                               $null,
                               $false,
                               $null) | %{$_.HostResource})

    foreach ($parentPoolAssignedResource in $parentPoolAssignedResources)
    {
      $poolInstanceId = $PathNameMap[$parentPoolAssignedResource]

      if (($poolInstanceId -eq $null) -or ($poolInstanceId -eq ""))
      {
        $PathNameMap.Add($parentPoolAssignedResource, $ParentPool.InstanceId)
      }
      elseif ($poolInstanceId -eq $ParentPool.InstanceId)
      {
        # Multiple parents.
      }
      else
      {
        $resultString +=
          "`t" + $poolInstanceId + "/" +
          $ParentPool.InstanceId + " ( " + $ParentPool.PoolId + " ): " +
          $parentPoolAssignedResource + "`n"
      }
    }
  }

  # Get the child pools decended from this pool.
  $childPools =
    @($ParentPool.GetRelated("Msvm_ResourcePool",
                             "Msvm_ElementAllocatedFromPool",
                             $null,
                             $null,
                             "Dependent",
                             "Antecedent",
                             $false,
                             $null))

  foreach ($childPool in $childPools)
  {
    # Call recursively for all child pools.
    $resultString += (VerifyStoragePathOnlyInOnePoolRecursive $childPool $PathNameMap)
  }

  $resultString
}


function VerifyStoragePathOnlyInOnePool($ResourceSubType)
#
# FUNCTION DESCRIPTION:
#   This function verified that a storage file path is assigned
#     to a single storage pool.
# 
# PARAMETERS:
#   ResourceSubType - the ResourceStorageSubType of the type of
#      storage file pool to verify.
#
# RETURN VALUES:
#   A string containing a newline seperated list of
#   pool Id related information for paths that failed the
#   verification.
#
{
  $resultString = ""

  # An association map, mapping a storage file path
  # to the instance id of the first pool found to
  # have it assigned.
  $pathNameMap = @{}

  $primordialPool =
      @($cache.Msvm_ResourcePoolMap[$ResourceSubType] |
        ?{($_.Primordial)})[0]

  if ($primordialPool -ne $null)
  {
    # Get the primordial pool's child pools.
    $childPools = 
        @($primordialPool.GetRelated("Msvm_ResourcePool",
                                     "Msvm_ElementAllocatedFromPool",
                                     $null,
                                     $null,
                                     "Dependent",
                                     "Antecedent",
                                     $false,
                                     $null))
  }

  foreach ($childPool in $childPools)
  {
    # For each child pool, verify the storage paths of it's descendents.
    $resultString += (VerifyStoragePathOnlyInOnePoolRecursive $childPool ($pathNameMap))
  }

  $resultString
}


function VerifyVirtualSwitchMandatoryExtensionsAreAvailable($Switch, [string[]]$MandatoryExtensions, [string[]]$MandatoryExtensionHints)
#
# FUNCTION DESCRIPTION:
#   For the specified virtual switch, this function
#   returns a string listing the unavailable mandatory switch extensions.
# 
# PARAMETERS:
#   $Switch - the virtual switch to verify.
# 
#   $MandatoryExtensions - and array of one or more mandatory switch extensions.
#
#   $MandatoryExtensionHints - and array of friendly names for one or more mandatory switch extensions.
#
# RETURN VALUES:
#  A string of unavailable mandatory switch extensions.
#
{
  $resultString = ""

  $enabledExtensionsMap =
    $cache.Msvm_InstalledVirtualSwitchExtensionsMap[$switch]

  for ($index = 0; $index -lt $MandatoryExtensions.Count; ++$index)
  {
    if ($enabledExtensionsMap[$MandatoryExtensions[$index]] -ne $true)
    {
      $resultString +=
        "`t" + $MandatoryExtensionHints[$index] + "`n"
    }
  }

  return $resultString
}


function VerifyVmMMandatoryVirtualSwitchExtensionsAreAvailable()
#
# FUNCTION DESCRIPTION:
#   Foreach VM which has a port connected to a virtual switch with one or more
#   mandatory switch extensions unavailable, this function returns a string
#   listing the VMs and the unavailable switch extensions.
# 
# PARAMETERS:
#   None.
#
# RETURN VALUES:
#  A string of VMs and mandatory switch extensions.
#
{
  $resultString = ""

  if ($cache.Msvm_VirtualSystemManagementService -ne $null)
  {
    $vms =
      @($cache.Msvm_VirtualSystemManagementService.GetRelated("Msvm_ComputerSystem",
                                                              "Msvm_ServiceAffectsElement",
                                                              $null,
                                                              $null,
                                                              $null,
                                                              $null,
                                                              $false,
                                                              $null))
  }

  foreach ($vm in $vms)
  {
    $unavailableExtensions = ""

    $vmGuid = $vm.Name
    $singleVmCache = $vmCache[$vmGuid]
    
    if ($singleVmCache -eq $null)
    {
      continue
    }

    # Skip the generic objects that define ranges or don't have
    # required features.
    $ethernetPortRasds =
      @($singleVmCache["Msvm_EthernetPortAllocationSettingData"] | 
        ?{$_.RequiredFeatures.Count -ne 0})

    foreach ($ethernetPortRasd in $ethernetPortRasds)
    {
      $switch = @()

      $switchPort =
        @($ethernetPortRasd.GetRelated("Msvm_EthernetSwitchPort",
                                       "Msvm_ElementSettingData",
                                       $null,
                                       $null,
                                       $null,
                                       $null,
                                       $false,
                                       $null))[0]

      if ($switchPort -ne $null)
      {
        $switch =
          @($cache.Msvm_VirtualEthernetSwitch | ?{$_.Name -like $switchPort.SystemName})[0]
      }
      else
      {
        # This could be an offline VM
        $hostResource = @($ethernetPortRasd.HostResource)[0]

        if ($hostResource -ne $null)
        {
          # This port is hard-affinitized to a switch.
          $switch =
              @($cache.Msvm_VirtualEthernetSwitch |
                 where {$_.__PATH -eq $hostResource})[0]
        }
        else
        {
          # This could be an offline VM w/ a dynamic port.
          # For now, we are not interested in this case. This is
          # for two reasons: when the VM is powered on the
          # cause of the failure will be obvious to the user.
          # Also, this check would not be 100% definitive
          # the VM coould power on, because there are other
          # reasons an attempt toe conect to a virtual switch
          # in a pool could fail.
        }
      }

      if ($switch -ne $null)
      {
        [string[]] $features = $ethernetPortRasd.RequiredFeatures
        [string[]] $hints = $ethernetPortRasd.RequiredFeatureHints

        $unavailableExtensions +=
          (VerifyVirtualSwitchMandatoryExtensionsAreAvailable $switch $features $hints)
      }
    }

    if ($unavailableExtensions.length -gt 1)
    {
      $resultString +=
        $vm.ElementName + " (" + $vm.Name + ")`n" +
        $unavailableExtensions 
    }
  }

  return $resultString
}

function IsWildcardMatch
#
# FUNCTION DESCRIPTION:
#   Checks if a string matches another string with wildcards satisfying the following rules.
#   1. On splitting the string at the first '.', both of them have 2 substrings.
#   2. The second substring matches character by character.
#   3. The first occurence of '*' is the last character of the first substring of the regex.  
#   4. The first substring of the given string matches the corresponding part of the regex. 
# 
# PARAMETERS:
#   $wildcard - The regex containing wildcards.
# 
#   $match - the string to be matched agains $wildcard.
#
# RETURN VALUES:
#  True if it matches, false otherwise.
#
{
  param (
    [string] $wildcard,
    [string] $match
  )
  $wildcardsplit = @($wildcard.split('.', 2))
  $matchsplit = @($match.split('.', 2))
  ($wildcardsplit.Count -eq 2) -and
    ($matchsplit.Count -eq 2) -and
    ($wildcardsplit.Get(1) -ieq $matchsplit.Get(1)) -and
    ($wildcardsplit.Get(0).IndexOf('*') -eq ($wildcardsplit.Get(0).Length -1)) -and
    ($matchsplit.Get(0) -like $wildcardsplit.Get(0)) 
}

function GetMatchingCerts
#
# FUNCTION DESCRIPTION:
#   Find certs that match the following conditions on the given machine.
#   1. Have the given signature info.
#   2. Have the given sig info.
#   3. Have Server auth EKU.
#   4. Pass full chain validation.
#   5. Have root cert with the given thumbprint.
# 
# PARAMETERS:
#   $MachineFQDN - The FQDN of the machine to search on.
# 
#   $RootCertThumbPrint - ThumbPrint of the root cert.
#
#   $SigInfoFQDN - Signature info field.
#
# RETURN VALUES:
#  An array of matching certificates.
#
{
  param(
    [string] $MachineFQDN,
    [string] $CertThumbPrint,
    [string] $SigInfoFQDN
  )

  $ro = [System.Security.Cryptography.X509Certificates.OpenFlags]::ReadOnly
  $lm = [System.Security.Cryptography.X509Certificates.StoreLocation]::LocalMachine
  
  $matchingCerts = @()

  $ErrorActionPreference = "Stop" # Convert non-terminating errors to terminating errors for this scope.
  try
  {
    # Open personal store.
    $storeMy = New-Object System.Security.Cryptography.X509Certificates.X509Store "\\$MachineFQDN\my", $lm
    $storeMy.Open($ro)

    # Find all certs in the personal store that:
    # - Have the given sig info.
    # - Have Server auth EKU.
    # - Pass full chain validation.
    # - Have root cert with the given thumbprint.
    $storeMy.Certificates | % {

      if($_.ThumbPrint -ieq $CertThumbPrint)
      {
        # List of DnsNames
        $dnsList = $_.DnsNameList | % { $_.Unicode }
        
        # Check if $SigInfoFQDN is present in the dns list.
        $match = $dnsList -icontains $SigInfoFQDN
        
        # If not, check if -
        # dns name has a wildcard,
        # it is a dns name in SAN and not in Subject with CN and
        # the given name matches the dns name
        if(!$match)
        {
          foreach ($dns in $dnsList)
          {
            $match = $match -or
                      (($dns.IndexOf('*') -ge 0) -and
                      ($_.Subject -ine ("CN={0}" -f $dns)) -and
                      (IsWildcardMatch $dns $SigInfoFQDN))
          }
        }
        # dns name matches and it has a server authentication EKU           
        if ($match -and
              (($_.EnhancedKeyUsageList | % { $_.ObjectId }) -icontains "1.3.6.1.5.5.7.3.1"))
        {
          $matchingCerts += Invoke-Command -computerName $MachineFQDN -ArgumentList $_ -ScriptBlock {
            param($cert)
            $chain = New-Object System.Security.Cryptography.X509Certificates.X509Chain
            $chain.ChainPolicy.RevocationFlag = "EntireChain"
            $chain.ChainPolicy.RevocationMode = "Offline"
            [void]$chain.Build($cert)

            $errors = @($chain.ChainStatus | ? { ($_.Status -ne "RevocationStatusUnknown") -and ($_.Status -ne "OfflineRevocation") } )
            if ($errors.Length -eq 0)
            {
              $cert
            }
          }
        }
      }
    }
  }
  catch
  {
  }

  $matchingCerts
}

#
# -------------------
# DISCOVERY FUNCTIONS
# -------------------
#

function DiscoverOS
#
# FUNCTION DESCRIPTION:
#   Discovers host OS properties
# 
# PARAMETERS:
#   None.
#
# RETURN VALUES:
#   $osNode - Object which contains interesting host OS properties
#
{
  $osNode = @{}

  $os = gwmi -n root\cimv2 Win32_OperatingSystem
  
  $osNode.name = $os.name
  $osNode.version = $os.version
  $osNode.sku = $os.OperatingSystemSKU
  $osNode.SystemDrive = $os.SystemDrive.ToLower()

  $registryFolder = (ls 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Server')|`
    ?{$_.PSChildName -eq "ServerLevels"}

  if ($registryFolder)
  {
    $serverCore = $registryFolder.GetValue(‘ServerCore’) -eq 1
    $serverCoreExtended = $registryFolder.GetValue(‘ServerCoreExtended’) -eq 1
    $serverGuiMgmt = $registryFolder.GetValue(‘Server-Gui-Mgmt’) -eq 1
    $serverGuiShell = $registryFolder.GetValue(‘Server-Gui-Shell’) -eq 1
  }

  $osNode.IsServerCore = $serverCore -and !$serverCoreExtended -and !$serverGuiMgmt -and !$serverGuiShell
  
  $WinBrand = add-type -name pinvoke -PassThru -memberDefinition @'
  [DllImport("kernel32.dll", CharSet = CharSet.Unicode)]
  public static extern IntPtr GlobalFree(IntPtr hMem);

  [DllImport("winbrand.dll", CharSet = CharSet.Unicode, ExactSpelling = true)] 
  private static extern IntPtr BrandingFormatString(string SrcString);

  public static string BrandingFormatStringWrap(string brandingTemplate)
  {
    string brandingResult = null;
    IntPtr brandingString = BrandingFormatString(brandingTemplate);
    if (brandingString != IntPtr.Zero)
    {
      brandingResult = Marshal.PtrToStringUni(brandingString);
      GlobalFree(brandingString);
    }
    return brandingResult;
  }
'@

  $osNode.Names = @{}
  $osNode.Names.Windows_Client_Version_6_2 = $WinBrand::BrandingFormatStringWrap('%WINDOWS_CLIENT_VERSION_6_2%')
  $osNode.Names.Windows_Server_Version_6_2 = $WinBrand::BrandingFormatStringWrap('%WINDOWS_SERVER_VERSION_6_2%')
  $osNode.Names.Windows_Short = $WinBrand::BrandingFormatStringWrap('%WINDOWS_SHORT%')

  $osNode
}


function DiscoverSnapshot($Snap)
#
# FUNCTION DESCRIPTION:
#   Discovers VM snapshot properties
# 
# PARAMETERS:
#   $Snap - the snapshot whose properties will be discovered
#
# RETURN VALUES:
#   $snapNode - Object which contains interesting snapshot properties
#
{
  $snapNode = @{}

  $snapNode.name = $Snap.ElementName
  $snapNode.created = $Snap.CreationTime

  $snapNode
}


function DiscoverVM($Vm)
#
# FUNCTION DESCRIPTION:
#   Discovers VM properties
# 
# PARAMETERS:
#   $Vm - the VM whose properties will be discovered
#
# RETURN VALUES:
#   $vmNode - Object which contains interesting VM properties
#
{
  $vmNode = @{}

  $vmNode.name = $Vm.ElementName
  $vmNode.lastSuccessfulBackupTime = $Vm.LastSuccessfulBackupTime
  
  $guidText = $Vm.Name
  $vmNode.guid = $guidText
  
  $singleVmCache = $vmCache[$guidText]
  
  if ($singleVmCache -eq $null)
  {
    return
  }
  
  $memory = $singleVmCache["Msvm_MemorySettingData"] | %{$_}
    
  $vmNode.memory = $memory.VirtualQuantity
  $vmNode.DMEnabled = $memory.DynamicMemoryEnabled
  $vmNode.DMMin = $memory.Reservation
  $vmNode.DMMax = $memory.Limit
  
  $procs = $singleVmCache["Msvm_Processor"] | %{$_}
    
  $vmNode.processor_count = if($procs.length){$procs.length}else{1}
  
  $vmNode.has_remotefx = [bool]($singleVmCache["Msvm_Synthetic3DDisplayControllerSettingData"] | %{$_})
  
  $vmNode.state = $Vm.EnabledState
  $vmNode.health = $Vm.HealthState
  
  # Gather useful summary information
  # 112 = MemoryAvailable
  $vssd = $singleVmCache["Msvm_VirtualSystemSettingData"] | `
    ?{$_.virtualsystemtype -eq "Microsoft:Hyper-V:System:Realized"}
  $vmNode.creationTime = $vssd.CreationTime
  $requestedInfo = @(112)
  $summaryInfo = $cache.Msvm_VirtualSystemManagementService.GetSummaryInformation(@($vssd), $requestedInfo).SummaryInformation[0]
  $vmNode.summaryinfo = $summaryInfo

  $vmNode.configurationDataRoot = $vssd.ConfigurationDataRoot.ToLower()
  $vmNode.snapshotDataRoot      = $vssd.SnapshotDataRoot.ToLower()
  $vmNode.swapFileDataRoot      = $vssd.SwapFileDataRoot.ToLower()
  
  # Detect SCSI command setting
  $vmNode.fullscsicommands = $vssd.AllowFullSCSICommandSet
  
  # Detect reduced fibre channel redundancy while LM setting
  $vmNode.reducedfcredundancy = $vssd.AllowReducedFcRedundancy
  
  # Note down the Failover IP Settings
  $vmNode.failover_ipadresses = @()
  $singleVmCache["Msvm_FailoverNetworkAdapterSettingData"] | `
    %{$vmNode.failover_ipadresses += $_.IPAddresses}

  # Detect virtual SCSI controller
  $scsi = $cache.Msvm_ScsiProtocolController | %{$_}
  $vmNode.scsi_enabled = 
    if($scsi)
    {
      $scsi.OperationalStatus[0] -eq 2 -or $scsi.OperationalStatus[0] -eq 3
    }
  
  # virtual disks information

  $disksInfo = @()
 
  $vhds = $singleVmCache["Msvm_StorageAllocationSettingData"] | %{$_}
  foreach ($vhd in $vhds)
  {
    if ($vhd)
    {
      $vhdSettingData = [xml]$cache.Msvm_ImageManagementService.GetVirtualHardDiskSettingData($vhd.HostResource[0]).SettingData
            
      $diskInfo = @{}
      $diskInfo.type = ($vhdSettingData.instance.property|?{$_.name -eq "Type"}).value
      $diskInfo.format = ($vhdSettingData.instance.property|?{$_.name -eq "Format"}).value
      $diskInfo.path = ($vhdSettingData.instance.property|?{$_.name -eq "Path"}).value
      $diskInfo.VhdPhysicalSectorSize = [int]($vhdSettingData.instance.property|?{$_.name -eq "PhysicalSectorSize"}).value
      
      $vhdState = [xml]$cache.Msvm_ImageManagementService.GetVirtualHardDiskState($vhd.HostResource[0]).State
      $diskInfo.PhysicalDiskSectorSize = [int]($vhdState.instance.property|?{$_.name -eq "PhysicalSectorSize"}).value

      if ($diskInfo.format -eq $STORAGE_FORMAT_VHD)
      {
        $diskInfo.is4kAligned = ($vhdState.instance.property|?{$_.name -eq "Alignment"}).value
      }
       
      $disksInfo += $diskInfo;
    }
  }

  $vmNode.disksInfo = $disksInfo
  
  # Detect virtual network adapter
  $endpoints = $singleVmCache["Msvm_LanEndpoint"] | %{$_}

  $enabled = 1
  foreach ($ep in $endpoints)
  {
    if($ep)
    {
      $enabled *= ($ep.OperationalStatus[0] -eq 2)
    }
  }
  
  $vmNode.network_enabled = 
    if ($endpoints)
    {
      [bool]$enabled
    }
  
  # Detect legacy network adapter
  $vmNode.legacy_network = [bool]($singleVmCache["Msvm_EmulatedEthernetPortSettingData"] | %{$_})
  
  # Detect virtual display adapter
  $synthdisplay = $singleVmCache["Msvm_SyntheticDisplayController"] | %{$_}
  $vmNode.display_enabled = 
    if($synthdisplay)
    {
      $synthdisplay.OperationalStatus[0] -eq 2
    }
  
  # Detect whether ICs are offered and/or enabled
  $ics = @{}
  
  $shutdown = @{}
  $ic = $singleVmCache["Msvm_ShutdownComponentSettingData"] | %{$_}
  $shutdown.offered = $ic.EnabledState -eq 2
  $shutdown.caption = $ic.Caption
  $ic = $singleVmCache["Msvm_ShutdownComponent"] | %{$_}
  $shutdown.enabled = 
    if ($ic.OperationalStatus)
    {
      -not ($ic.OperationalStatus[0] -eq 12 -or $ic.OperationalStatus[0] -eq 13)
    }
  $ics.shutdown = $shutdown
  
  $timesync = @{}
  $ic = $singleVmCache["Msvm_TimeSyncComponentSettingData"] | %{$_}
  $timesync.offered = $ic.EnabledState -eq 2
  $timesync.caption = $ic.Caption
  $ic = $singleVmCache["Msvm_TimeSyncComponent"] | %{$_}
  $timesync.enabled = `
    if ($ic.OperationalStatus)
    {
        -not ($ic.OperationalStatus[0] -eq 12 -or $ic.OperationalStatus[0] -eq 13)
    }
  $ics.timesync = $timesync
  
  $heartbeat = @{}
  $IC = $singleVmCache["Msvm_HeartbeatComponentSettingData"] | %{$_}
  $heartbeat.offered = $IC.EnabledState -eq 2
  $heartbeat.caption = $IC.Caption
  $IC = $singleVmCache["Msvm_HeartbeatComponent"] | %{$_}
  $heartbeat.enabled = 
    if ($IC.OperationalStatus)
    {
      -not ($IC.OperationalStatus[0] -eq 12 -or $IC.OperationalStatus[0] -eq 13)
    }
  $ics.heartbeat = $heartbeat
  
  $vss = @{}
  $ic = $singleVmCache["Msvm_VssComponentSettingData"] | %{$_}
  $vss.offered = $ic.EnabledState -eq 2
  $vss.caption = $ic.Caption
  $ic = $cache.Msvm_VssComponent | %{$_}
  $vss.enabled = 
    if ($ic.OperationalStatus)
    {
      -not ($ic.OperationalStatus[0] -eq 12 -or $ic.OperationalStatus[0] -eq 13)
    }
  $ics.vss = $vss
  
  $kvpexchange = @{}
  $ic = $singleVmCache["Msvm_KvpExchangeComponentSettingData"] | %{$_}
  $kvpexchange.offered = $ic.EnabledState -eq 2
  $kvpexchange.caption = $ic.Caption
  $ic = $singleVmCache["Msvm_KvpExchangeComponent"] | %{$_}
  $kvpexchange.enabled =
    if ($ic.OperationalStatus)
    {
      -not ($ic.OperationalStatus[0] -eq 12 -or $ic.OperationalStatus[0] -eq 13)
    }
  
  # Iterate through available kvps if vm is running
  # (for now, just get guest intrinsic items as other kvps are not needed)
  $guestIntrinsic = 
    if($Vm.EnabledState -eq 2 -and $kvpexchange.enabled)
    {
      (GetKvpHashFromXml $ic.GuestIntrinsicExchangeItems)
    }
  $kvpexchange.guestintrinsic = $guestIntrinsic
  $ics.kvpexchange = $kvpexchange
  
  $vmNode.ICs = $ics

  # Find the Replication settings.

  $Replication = $singleVmCache["Msvm_ReplicationSettingData"] | %{$_}

  $vmNode.Replication = $Replication
  $vmNode.ReplicationMode = $Vm.ReplicationMode
  $vmNode.ReplicationState = $Vm.ReplicationState
  $vmNode.ReplicationProperties = @{ }
  $vmFr = $cache.Msvm_ReplicationService
  $replStats = @($vmFr.GetReplicationStatistics($Vm).ReplicationStatistics)
  $replStatsCurrXml = [xml]($replStats[$replStats.Length - 1])
  $lastPFRT = $replStatsCurrXml.INSTANCE.PROPERTY | ? { $_.Name -ieq "LastTestFailoverTime" } | % { $_.Value }
  if ($lastPFRT -ne $null)
  {
    $vmNode.ReplicationProperties.LastTestFailoverTime = [Management.ManagementDateTimeconverter]::ToDateTime($lastPFRT).ToUniversalTime()
  }
  $lastLCCT = $replStatsCurrXml.INSTANCE.PROPERTY | ? { $_.Name -ieq "LastConsistencyCheckTime" } | % { $_.Value }
  if ($lastLCCT -ne $null)
  {
    $vmNode.ReplicationProperties.LastConsistencyCheckTime = [Management.ManagementDateTimeconverter]::ToDateTime($lastLCCT).ToUniversalTime()
  }
  $lastLCCR = $replStatsCurrXml.INSTANCE.PROPERTY | ? { $_.Name -ieq "LastConsistencyCheckResult" } | % { $_.Value }
  if ($lastLCCR -ne $null)
  {
    $vmNode.ReplicationProperties.LastConsistencyCheckResult = $lastLCCR
    $vmNode.ReplicationProperties.LastConsistencyCheckCompleted = (
      ($vmNode.ReplicationProperties.LastConsistencyCheckResult -eq $S_OK) -or
      ($vmNode.ReplicationProperties.LastConsistencyCheckResult -eq $VM_E_FR_CC_INCONSISTENCIES_DETECTED))
  }
  
  # Iterate through snapshots, if any
  $snapList = $singleVmCache["Msvm_VirtualSystemSettingData"] | `
    ?{$_.virtualsystemtype -eq "Microsoft:Hyper-V:Snapshot:Realized"}
  $vmNode.snap_count = 
    if ($snapList.length)
    {
      $snapList.length
    }
    elseif ($snapList -ne $null)
    {
      1
    }
    else
    {
      0
    }
  $vmNode.full_snap_count = @($singleVmCache["Msvm_VirtualSystemSettingData"] | `
    ?{$_.virtualsystemtype -ne "Microsoft:Hyper-V:System:Realized"}).length
    
  $snapshots = @()
  foreach ($snap in $snapList)
  {
    if ($snap)
    {
      $snapshots += (DiscoverSnapshot $snap)
    }
  }
  $vmNode.snapshots = $snapshots
  
  # Synthetic FibreChannel Ports
  $vmNode.SynthFCRASD = @($singleVmCache["Msvm_FCPortAllocationSettingData"] | %{$_})
    
  $vmNode.runningCurrently = $false
  if ($vm.EnabledState -eq $RUNNING)
  {
    $vmNode.runningCurrently = $true
  }
  
  # Networking Rules
  # Port Mirroring - 437 & 438
  if ($vmNode.runningCurrently -eq $true)
  {
    $connectionRASD = @($singleVmCache["Msvm_EthernetPortAllocationSettingData"] | %{$_})
  
    foreach ($connRASD in $connectionRASD)
    {    
      # There is no other way of retrieving the associated SwitchPort
      $port = $connRASD.GetRelated("Msvm_EthernetSwitchPort",
                                   "Msvm_ElementSettingData",
                                   $null,
                                   $null,
                                   $null,
                                   $null,
                                   $false,
                                   $null)
      if ($port.Count -ne 1)
      {
        continue;
      }
      $port = $port | %{$_}
        
      $switchId = $port.SystemName 
      
      # 437 & 438
      # Checking if the adapter has been set as a 
      # Source or Destination for Port Mirroring
      $map = $discov.parent.networking.switchMap[$switchId]
      if ($map -ne $null)
      {
        $connId = $connRASD.InstanceId
        $connSecSD = $singleVmCache["Msvm_EthernetSwitchPortSecuritySettingData"] |`
                     ?{$_.InstanceId -like "*$connId*"}
        if ($connSecSD.MonitorMode -eq 1 -and $map.DestinationMirrors -ne $null)
        {
            # Checking for Destination Ports
            $vmText = $vmNode.Name + " (" + $vmNode.guid + ")"
            $map.DestinationMirrors[$vmText] = $true
            break
        }
        elseif ($connSecSD.MonitorMode -eq 2 -and $map.SourceMirrors -ne $null)
        {
          # Checking for Source Ports
          $vmText = $vmNode.Name + " (" + $vmNode.guid + ")"
          $map.SourceMirrors[$vmText] = $true
          break
        }
      }
    }
  }
  
  
  if ($discov.parent.networking.SupportsIov -eq $true)
  {
    # Caching Data for IOV Rules (401-405)
    $vmnode.OSsupportsIOV = $false
    if ($vmNode.ICs.kvpexchange.guestintrinsic)
    {
      $vmOStype = (GetOsType $vmnode.ICs.kvpexchange)
      if (($vmOStype -eq $OSTYPE_SERVER_VERSION_6POINT2 -or 
           $vmOStype -eq $OSTYPE_VERSION_6POINT2) -and
           $vmNode.ICs.kvpexchange.ProcessorArchitecture -ne 0)
      {
        # Windows OS Version 6.2 x64 supports IOV.
        $vmnode.OSsupportsIOV = $true
      }
    }
  
    if ($vmNode.runningCurrently -eq $true)
    {
      $connectionRASD = @($singleVmCache["Msvm_EthernetPortAllocationSettingData"] | %{$_})
      $vmNode.connections = @()
    
      foreach ($connRASD in $connectionRASD)
      {    
        $connection = @{}
        $connection.IovOffloadWeight = 0
        $connection.portIOVOffloadUsage =  $null
        $connection.switch = @{}
        # When $connection.switch.IOVPreferred is $false, there are no checks performed.
        $connection.switch.IOVPreferred = $false
        $connection.switch.IOVSupported = $false
        $connection.switch.MaxIOVOffloads = $null
        $connection.switch.VFOffloads = $null
      
        $connId = $connRASD.InstanceId
                
        $connFSD = @($cache.Msvm_EthernetSwitchPortOffloadSettingData |
                     ?{$_.InstanceId -like "*$connId*"})
                 
        if ($connFSD.Count -ne 1)
        {
          # Assign Default Value. Try retrieving from Default RASD
          $connection.IovOffloadWeight = 0;
        }
        else
        {
          $connFSD = $connFSD | %{$_}
          $connection.IovOffloadWeight = $connFSD.IovOffloadWeight
        }
      
        # Looking for ResourcePools connections now
        $poolPath = @($cache.Msvm_ResourceAllocationFromPool | ?{$_.Dependent -like "*$($connId.Replace('\', '\\'))*"})
          
        if ($poolPath.Count -eq 1)
        {
          $connPool = $discov.parent.networking.EthernetPools | ?{"$($poolPath[0].Antecedent)" -like  "*$($_.Guid)*"}
          
          if ($connPool.Primordial -eq $false)
          {
            $connection.pool = @{}
            $connection.pool.MaxIOVOffloads = $connPool.poolVfCapacity
            $connection.pool.VFOffloads = $connPool.poolVfsInUse
          }
        }

        # There is no other way of retrieving the associated SwitchPort
        $port = $connRASD.GetRelated("Msvm_EthernetSwitchPort",
                                     "Msvm_ElementSettingData",
                                     $null,
                                     $null,
                                     $null,
                                     $null,
                                     $false,
                                     $null)
        if ($port.Count -ne 1)
        {
          $connection.switch.IOVPreferred = $false
          $vmNode.connections += $connection
          continue;
        }
        $port = $port | %{$_}
      
        $portId = $port.Name
        $portOffloadData = @($cache.Msvm_EthernetSwitchPortOffloadData |
                             ?{$_.DeviceId -like "$portId"})
                           
        if ($portOffloadData.Count -ne 1)
        {
          # Wait for the search for Switch to fail before
          # declaring IOVPreferred as $false.
          $connection.portIOVOffloadUsage = 0
          $connection.portIovVfDataPathActive = $false
          $vmNode.connections += $connection
          continue;
        }
      
        $portOffloadData = $portOffloadData | %{$_}                   
        $connection.portIOVOffloadUsage =  $portOffloadData.IOVOffloadUsage
        $connection.portIovVfDataPathActive = $portOffloadData.IovVfDataPathActive
    
        if ($connection.pool -ne $null)
        {
          # As the network adapter is connected to a resource pool,
          # there is no need to check the switch-related data
          $vmNode.connections += $connection
          continue;
        }
        
        $switchId = $portOffloadData.SystemName 
            
        # Find whether the switch has IOV Support
        
        $switch = $cache.Msvm_VirtualEthernetSwitch | ?{$_.Name -like "*$switchId*"}

        $ExternalPort = @(GetPortsFromVirtualSwitch $switch "Msvm_ExternalEthernetPort")
        $ExternalPortGuid = "{"
        
        if ($ExternalPort.Count -eq 1)
        {
          $ExternalPort = $ExternalPort[0]
          $ExternalPortGuid = $ExternalPort.DeviceId
          $ExternalPortGuid = $ExternalPortGuid.Split(":")[1]
        }
        
        $ExternalPortCapabilities = @($cache.Msvm_ExternalEthernetPortCapabilities | ?{$_.InstanceId -like "*$ExternalPortGuid*"})
        
        if ($ExternalPortCapabilities.Count -eq 1)
        {
          $connection.switch.IOVSupported = $ExternalPortCapabilities[0].IOVSupport
        }
              
        $switchSettings = @($cache.Msvm_VirtualEthernetSwitchSettingData |
                            ?{$_.InstanceId -like "*$switchId*"})
        if ($switchSettings.Count -ne 1)
        {
          $connection.switch.IOVPreferred = $false
          $vmNode.connections += $connection
          continue;
        }
        $switchSettings = $switchSettings | %{$_}
        $connection.switch.IOVPreferred = $switchSettings.IOVPreferred
      
        $switchOffloadData = @($cache.Msvm_EthernetSwitchHardwareOffloadData |
                               ?{$_.SystemName -like "$switchId"})
        if ($switchOffloadData.Count -ne 1)
        {
          $vmNode.connections += $connection
          continue;
        }
        $switchOffloadData = $switchOffloadData | %{$_}
      
        $connection.switch.MaxIOVOffloads = $switchOffloadData.IovVfCapacity
        $connection.switch.VFOffloads = $switchOffloadData.IovVfUsage
    
        # Adding connection to array.
        $vmNode.connections += $connection    
      }
    }
  }
  
  $vmNode
}


function DiscoverVmms
#
# FUNCTION DESCRIPTION:
#   Discovers VMMS properties
# 
# PARAMETERS:
#   None.
#
# RETURN VALUES:
#   $vmmsNode - Object which contains interesting VMMS properties
#
{
  $vmmsNode = @{}

  # Check to see if vmms is running 
  $vmmsNode.running = ((Get-Service vmms -ErrorAction silentlyContinue).status -eq "Running")

  # Check if service is configured for autostart
  $vmmsNode.starttype = (gwmi Win32_Service -filter "Name = 'vmms'").startmode
  
  if ($cache.Msvm_VirtualSystemManagementService -ne $null)
  {
    # Get list of configured VMs
    $vmList = $cache.Msvm_VirtualSystemManagementService.getrelated(
      "Msvm_ComputerSystem","Msvm_ServiceAffectsElement",$null,$null,$null,$null,$false,$null)|%{$_}
  }
  
  # Get data for each installed vm
  $vms = @()
  foreach ($vm in $vmList)
  {
    if ($vm)
    {
      $vms += (DiscoverVM $vm)
    }
  }
  $vmmsNode.virtual_machines = $vms

  $vmmsNode
}


function DiscoverNetworkSettings
#
# FUNCTION DESCRIPTION:
#   Discovers host networking properties
# 
# PARAMETERS:
#   None.
#
# RETURN VALUES:
#   $network - Object which contains interesting host networking properties
#
{
  $network = @{}
  
  # Get domain name
  $win32CS = gwmi Win32_ComputerSystem
  if (0,2 -contains $win32CS.domainrole)
  {
    # This is a standalone workstation or server, so leave domain blank.
    $network.domain = $null
  }
  else
  {
    $network.domain = $win32CS.domain
  }
  
  # Iterate through active NICs
  $NICs = $cache.Msvm_ExternalEthernetPort
  $network.NIC_count = 
    if ($NICs.length)
    {
      $NICs.length
    }
    else
    {
      1
    }
    
  $NICsNode = @()
  foreach ($nic in $NICs)
  {
    $nicInfo = @{}
    $nicInfo.description = $nic.ElementName
    $nicInfo.sharedVNIC = (GetInternalPortsFromExternalPort $nic).ElementName
    $NicsNode += $nicInfo
  }
  $network.NICs = $NICsNode
  
  # Determine range of available MAC Addresses
  $network.MACrange = GetMacAddressRangeSize
  
  # Iterate through vSwitches
  $vSwitchesNode = @()
  foreach ($vswitch in $cache.Msvm_VirtualEthernetSwitch)
  {
    $vswitchInfo = @{}
    $vswitchInfo.description = $vswitch.ElementName
    $vswitchInfo.guid = $vswitch.Name
    
    $connectedInternalPorts = @(GetPortsFromVirtualSwitch $vswitch "Msvm_InternalEthernetPort")
    
    $vswitchInfo.SharedWithHost = [bool]$connectedInternalPorts
    $macaddresses = @($connectedInternalPorts | %{$_.PermanentAddress})
    $netadapters = @($cache.Win32_NetworkAdapter | `
      ?{$_.MACAddress -and $macaddresses -contains ($_.MACAddress).replace(":","") -and $_.ServiceName -eq "VMSMP"})
    $deviceIDs = @($netadapters|%{"$($_.DeviceID)"})
    $vswitchInfo.enabled = $macaddresses.length -eq @($cache.Win32_NetworkAdapterConfiguration |?{$deviceIds -contains $_.Index}).length
    $vSwitchesNode += $vswitchInfo
  }
  $network.vSwitches = $vSwitchesNode
  
  # Checking if the host supports IOV
  $network.SupportsIov = $cache.Msvm_VirtualEthernetSwitchManagementCapabilities.IOVSupport
  
  if ($network.SupportsIov -eq $true)
  {
    $ethernetResourceType = "Microsoft:Hyper-V:Ethernet Connection"
    $ethernetPools = $cache.Msvm_ResourcePoolMap[$ethernetResourceType]
    
    $poolSettings = @()
    foreach ($epool in $ethernetPools)
    {
      $poolData = @{}
      $guidtext = $epool.InstanceId.Split(":")[1]
      $poolData.Guid = $guidtext
      $poolData.Primordial = $epool.Primordial
      
      $poolPortRASDs = $cache.Msvm_EthernetPortAllocationSettingData | ?{$_.InstanceId -like "Microsoft:Pool\$guidText*"}
      $switchPaths = $poolPortRASDS | %{$_.HostResource}

      $vfsInUse = 0
      $totalVfCount = 0
      
      foreach ($switchPath in $switchPaths)
      {
        $switchGuid = $switchPath.split('"')[3]
        $IovData = $cache.Msvm_EthernetSwitchHardwareOffloadData | ?{$_.SystemName -like "$switchGuid"}
        $totalVfCount += $IovData.IovVfCapacity
        $VfsInUse += $IovData.IovVfUsage
      }

      $poolData.poolVfCapacity = $totalVfCount
      $poolData.poolVfsInUse = $vfsInUse
      
      $poolSettings += $poolData
    }
    $network.EthernetPools = $poolSettings
  }
  
  # Data collection for Networking Rules
  $wfpSwitchExtensions = $cache.Msvm_EthernetSwitchExtension | ?{$_.ElementName -like "Microsoft Windows Filtering Platform"}

  foreach ($vswitch in $network.vSwitches)
  {
    # There is at most one external port per vSwitch as of Windows8
    $externalport = $cache.SwitchToExternalPortMap[$vswitch.guid]
 
    if ($externalport -ne $null)
    {
      $tnic = $cache.MSFT_NetLbfoTeamNic | `
        ?{$_.interfacedescription -eq $externalport.name}
    
      if ($tnic -ne $null)
      {
        # 434
        $siblingtnic = @($cache.MSFT_NetLbfoTeamNic | ?{$_.team -eq $tnic.team})
        $vswitch.numSiblingTnics = $siblingtnic.length

        # 435
        $vswitch.tnicDefaultMode = $tnic.default          
      }

      # 436
      $vmqnic = $cache.MSFT_NetAdapterVmqSettingData | `
        ?{$_.interfacedescription -eq $externalport.name}

      if ($vmqnic -ne $null)
      {
        $vswitch.VmqEnabled = $vmqnic.Enabled
      }
    }
    # 440
    # Assuming that there will be only zero or one "Windows Filtering Platform" extension per switch
    $vswitch.wfpExtension = $wfpSwitchExtensions | ?{$_.SystemName -like $vswitch.Guid}
  }

  # 437 and 438
  # Mapping Virtual Switches to their EthernetSwitchPorts that connect to corresponding Msvm_ExternalEthernetPort and connections
  $network.switchMap = @{}
  foreach ($vswitch in $network.vswitches)
  {
    $network.switchMap[$vswitch.guid] = @{}
    $network.switchMap[$vswitch.guid].externalSwitchPort = ""
    $network.switchMap[$vswitch.guid].SourceMirrors = @{}
    $network.switchMap[$vswitch.guid].DestinationMirrors = @{}
  }

  $switchPortGuidIndex = 0
  $switchGuidIndex = 0
  if ($cache.Msvm_ActiveConnection -ne $null)
  {
    $endPointPath= $cache.Msvm_ActiveConnection[0].Antecedent
    $switchPortGuidStr = ',Name="Microsoft:'
    $switchPortGuidIndex = $endPointPath.IndexOf($switchPortGuidStr) + $switchPortGuidStr.length
    $switchGuidStr = 'SystemName="'
    $switchGuidIndex = $endPointPath.IndexOf($switchGuidStr) + $switchGuidStr.length
  }

  foreach ($eport in $cache.Msvm_ExternalEthernetPort)
  {
    $portConnection = $cache.Msvm_ActiveConnection | ?{$_.dependent -like "*$($eport.DeviceId)*"}

    if ($portConnection -eq $null)
    {
      continue
    }  
    $switchGuid = $portConnection.Antecedent.Substring($switchGuidIndex, 36)
    $switchPortGuid = $portConnection.Antecedent.Substring($switchPortGuidIndex, 36)
  
    $network.switchMap[$switchGuid].externalSwitchPort = $switchPortGuid
  }

  foreach ($portSecuritySD in $cache.Msvm_EthernetSwitchPortSecuritySettingData)
  {
    $instanceId = $portSecuritySD.InstanceId
    $systemName = $instanceId.Substring(10,36)
  
    # $systemName can be a switch Guid or a VM Guid
    $map = $network.switchMap[$systemName]
  
    # Is the Security SD a Host OS SD?
    if ($map -ne $null -and $instanceId.Substring(47, 36) -ne $map.externalSwitchPort)
    {
      if ($portSecuritySD.MonitorMode -eq 1)
      {
        # Checking for Destination Ports
        $map.DestinationMirrors["Management OS"] = $true
      }
      elseif ($portSecuritySD.MonitorMode -eq 2)
      {
        # Checking for Source Ports
        $map.SourceMirrors["Management OS"] = $true
      }
    }
  }

  $network
}

function DiscoverSynthFCSettings
#
# FUNCTION DESCRIPTION:
#   Discovers the Host's SynthFC ResourcePools' properties
# 
# PARAMETERS:
#   None.
#
# RETURN VALUES:
#   $SynthFCPools - Array which contains interesting properties of every virtual SAN
#
{
  $FCresourcePools = gwmi -n $V2_NS -Query "Select * from Msvm_ResourcePool where ResourceType=64764 AND Primordial=FALSE"
  $SynthFCPools = @()

  foreach ($FCresourcepool in $FCResourcepools)
  {
    $FCresourcepoolInfo = @{}
    $FCresourcepoolInfo.poolId = $FCresourcepool.PoolID
    $FCresourcePoolInfo.InstanceId = $FCresourcepool.InstanceID
    $FCresourcePoolInfo.IsAssignedHBA = $false
  
    $FCconRASD = $FCresourcePool.getRelated("Msvm_FCPortAllocationSettingData");
    if ($FCconRASD.count -ne 1)
    {
      $SynthFCPools += $FCresourcePoolInfo
      continue
    }

    $FCconRASD = $FCconRASD | %{$_}

    $switch = $null
    foreach ($hostResource in $fCconRASD.HostResource)
    {
      $wmiInstance = [wmi]$hostResource
      if ($wmiInstance -ne $null -and
            $wmiInstance.__CLASS -eq "Msvm_VirtualFCSwitch")
      {
        $switch = $wmiInstance
        $ExternalFCport = @(GetFCPortsFromVirtualFCSwitch $switch "Msvm_ExternalFCPort")
        if ($ExternalFCPort.Count -gt 0)
        {
          $FCResourcePoolInfo.IsAssignedHBA = $true
          break
        }
      }
    }
    $SynthFCPools += $FCresourcePoolInfo
  }
  $SynthFCPools
}

function DiscoverParent
#
# FUNCTION DESCRIPTION:
#   Discovers host properties
# 
# PARAMETERS:
#   None.
#
# RETURN VALUES:
#   $hostNode - Object which contains interesting host properties
#
{
  $hostNode = @{}

  $hostNode.os = (DiscoverOS)
  $hostNode.networking = (DiscoverNetworkSettings)

  # Get count of installed roles
  Import-Module ServerManager
  $rlcnt = @(Get-WindowsFeature | ?{`
    $_.FeatureType -eq 'Role' -and `
    $_.Installed -and `
    (($_.subfeatures|?{`
        $_ -ne "File-Services" -and `
        $_ -ne "Storage-Services" -and `
        $_ -ne "RDS-Virtualization" -and `
        $_ -ne "RDS-Virtualization-Core"}|?{`
            (get-windowsfeature -name $_).installed}
        ) -or `
        !$_.subfeatures)`
    }).length
  $hostNode.role_count = if($rlcnt){$rlcnt}else{1}
  
  # Get count of logical processors
  $lpcount = 0
  gwmi Win32_Processor | %{$lpcount += $_.NumberOfLogicalProcessors}
  $hostNode.logicalproc_count = $lpcount
  
  # Get version of Integration Services on host
  $hostNode.GuestInstallerVersion = 
    (ls 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Virtualization\GuestInstaller').`
    GetValue("Microsoft-Hyper-V-Guest-Installer-Win6x-Package")
    
  # Determine if host is using EEC RAM and sum total RAM in MB
  $ram = gwmi Win32_PhysicalMemory | ?{$_.TypeDetail -ne 4096}
  $hostNode.EECRAM = $true
  $hostNode.physicalmemory = 0
  foreach ($stick in $ram)
  {
    $hostNode.physicalmemory += $stick.capacity/1mb
    if ($stick.DataWidth -eq $stick.TotalWidth)
    {
      $hostNode.EECRAM = $false
      break
    }
  }

  # Determine the RemoteFX capabilities of the host
  $hostNode.RemoteFX_Installed = (get-windowsfeature -name "RDS-Virtualization").installed
  $hostNode.IsSLATCapable = $cache.Msvm_Synth3dVideoPool.IsSLATCapable
  $hostNode.IsGPUCapable = $cache.Msvm_Synth3dVideoPool.IsGPUCapable
  
  # Discover SynthFC child Resource Pools (Virtual SANs).
  $hostNode.SynthFCPools = DiscoverSynthFCSettings
  
  $hostNode
}


function DiscoverHypervisor
#
# FUNCTION DESCRIPTION:
#   Discovers hypervisor properties
# 
# PARAMETERS:
#   None.
#
# RETURN VALUES:
#   $hypervisorNode - Object which contains interesting hypervisor properties
#
{
  $hypervisorNode = @{}
  
  $hypervisorNode.running = (gwmi -ErrorAction SilentlyContinue Win32_ComputerSystem).HypervisorPresent
  
  $hypervisorNode
}


function DiscoverHyperV
#
# FUNCTION DESCRIPTION:
#   Discovers Hyper-V platform properties
# 
# PARAMETERS:
#   None.
#
# RETURN VALUES:
#   $hv - Object which contains interesting Hyper-V platform properties
#
{
  $hv = @{}
  
  $hv.hypervisor = (DiscoverHypervisor)
  $hv.vmms = (DiscoverVmms)
  
  $hv
}


#
# ------------------------
# RULE VIOLATION GENERATOR
# ------------------------
#

function RuleViolation
#
# FUNCTION DESCRIPTION:
#   Reports a BPA rule violation
#   NOTE: This function uses global variables defined in MAIN section
# 
# PARAMETERS:
#   [varargs] List of violation descriptors
#
# RETURN VALUES:
#   None.
#
{
  $violation = $addElem.invoke($create.invoke("violation"))
  $id = $violation.appendChild($create.invoke("ID"))
  if ($args.length -gt 1)
  {
    $id.InnerText = $args[0]
    $args[1..($args.length-1)] | `
      foreach `
      {
        $context = $violation.appendChild($create.invoke("context"))
        $context.InnerText = $_
      }
  }
  else
  {
    $id.InnerText = $args
  }    
}


#
# ------------------------
# RULE VIOLATION DETECTORS
# ------------------------
#
# These use the limits defined in the Global Limits section
#
$detectors = {

#
# RULES 1-20: Prerequisites
#

# Rule 1 - Hypervisor must be running
if (-not $discov.hyperv.hypervisor.running)
{
  RuleViolation 1
}

# Rule 2 - VMMS must be running
if (-not $discov.hyperv.vmms.running)
{
  RuleViolation 2
}


#
# RULES 21-50: Hyper-V Role and VM Configuration
#

# Rule 21 - VMMS should start automatically
if ($discov.hyperv.vmms.starttype -ne "Auto")
{
  RuleViolation 21
}

# Rule 24 - Hyper-V should be only installed role
if ($discov.parent.role_count -gt 1)
{
  RuleViolation 24
}

# Rule 25 - Server Core or Hyper-V Server is recommended
if ($discov.parent.os.IsServerCore -ne $true)
{
  RuleViolation 25
}

# Rule 26 - Domain joined servers are recommended
if (-not $discov.parent.networking.domain)
{
  RuleViolation 26
}

# Rule 27 - Should have no Paused VMs
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ($vm.state -eq $PAUSED)
  {
    $ids += $vm.name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 27 $ids.substring(0, $ids.length - 1)
}

# Rule 28 - ICs should be offered to guests
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  $ids2 = ""
  foreach ($ic in $vm.ICs.keys)
  {
    if (-not $vm.ICs.Item($ic).offered)
    {
      $ids2 += "`t"+$vm.ICs.Item($ic).caption + "`n"
    }
  }
  if ($ids2.length -gt 1)
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n$ids2"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 28 $ids.substring(0, $ids.length - 1)
}

# Rule 29 - SCSI Controller should be enabled
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ($vm.ICs.heartbeat.enabled -and
      -not $vm.scsi_enabled -and
      $vm.scsi_enabled -ne $null)
  {
    $ids += $vm.name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 29 $ids.substring(0, $ids.length - 1)
}

# Rule 30 - Display Adapters should be enabled
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ($vm.ICs.heartbeat.enabled -and
      -not $vm.display_enabled -and
      $vm.display_enabled -ne $null)
  {
    $ids += $vm.name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 30 $ids.substring(0, $ids.length - 1)
}

# Rule 31 - Guests should use latest available Integration Services Drivers
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ($vm.ICs.heartbeat.enabled -and
      $vm.ICs.kvpexchange.guestintrinsic -and 
      $vm.ICs.kvpexchange.guestintrinsic.IntegrationServicesVersion -lt $discov.parent.GuestInstallerVersion)
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if($ids.length -gt 1)
{
  RuleViolation 31 $ids.substring(0, $ids.length - 1)
}

# Rule 32 - Integration Services should be enabled
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  $ids2 = ""
  foreach ($ic in $vm.ICs.keys)
  {
    # The exception is VSS on Server 2003 and XP v5.1, as this is never supported.
    if ($vm.ICs.heartbeat.enabled -and
        -not $vm.ICs.Item($ic).enabled -and 
        $vm.ICs.Item($ic).enabled -ne $null -and
        !($ic -eq "vss" -and
          $vm.ICs.kvpexchange.guestintrinsic.OSVersion -like "5.*" -and
          ($vm.ICs.kvpexchange.guestintrinsic.OSVersion -notlike "*.2" -or
           [int]$vm.ICs.kvpexchange.guestintrinsic.ProductType -eq 1)))
    {
      $ids2 += "`t"+$vm.ICs.Item($ic).caption + "`n"
    }
  }
  if ($ids2.length -gt 1)
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n$ids2"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 32 $ids.substring(0, $ids.length - 1)
}


#
# RULES 51-80: Policy
#

# Rule 51 - No more logical processors than supported
if ($discov.parent.logicalproc_count -gt $MAX_LOGICAL_PROCESSORS)
{
  RuleViolation 51
}

# Rule 53 - EEC RAM should be used
if (-not $discov.parent.EECRAM)
{
  RuleViolation 53 $discov.parent.os.Names.Windows_Server_Version_6_2
}

# Rule 54 - No more VMs than officially supported
if ($discov.hyperv.vmms.virtual_machines.length -gt $MAX_CONFIGURED_VMS)
{
  RuleViolation 54
}

# Rule 55 - RemoteFX only on SLAT capable machines
if (-not $discov.parent.IsSLATCapable -and 
    ([bool]($discov.hyperv.vmms.virtual_machines|?{$_.has_remotefx}) -or
    $discov.parent.RemoteFX_Installed))
{
  RuleViolation 55
}

# Rule 56 - RemoteFX requires supported graphics hardware
if (-not $discov.parent.IsGPUCapable -and
    ([bool]($discov.hyperv.vmms.virtual_machines|?{$_.has_remotefx}) -or
    $discov.parent.RemoteFX_Installed))
{
  RuleViolation 56
}

# Rule 57 - RemoteFX cannot run with an Active Directory Domain Controller
Import-Module ServerManager
$addscnt = @(Get-WindowsFeature | ?{`
$_.FeatureType -eq 'Role' -and `
$_.Installed -and `
($_.Name -eq "AD-Domain-Services")`
}).length

$rdscnt = @(Get-Windowsfeature | ?{`
$_.Featuretype -eq 'Role' -and $_.Installed`
 -and ($_.Name -eq "Remote-Desktop-Services")`
 -and ($_.subfeatures | ?{$_ -eq "RDS-Virtualization"}`
 | ?{(get-windowsfeature -name $_).installed}) }).length

$hypervcnt = @(Get-Windowsfeature | ?{`
$_.Featuretype -eq 'Role' -and $_.Installed`
 -and ($_.Name -eq "Hyper-V")} ).length

if (($addscnt -eq 1) -and ($rdscnt -eq 1) -and ($hypervcnt -eq 1))
{
  RuleViolation 57
}

# Rule 59 - Use at least SMB protocol version 3.0 for file shares that store files for virtual machines.
# Rule 60 - Use at least SMB protocol version 3.0 configured for continuous availability on file shares that store files for virtual machines.

$smbVersionViolation = ""
$smbCaViolation = ""

$smbServersViolatingVersion = @()
$smbServersViolatingCaSupport = @()

$smbDriveLettersViolatingVersion = @()
$smbDriveLettersViolatingCaSupport = @()

$filepaths =  @();

$filePathsViolatingVersion = ""
$filePathsViolatingCaSupport = ""

$smbConnections = Get-SmbConnection

foreach ($connection in $smbConnections)
{
   [System.double]$version = [System.Convert]::ToDouble($connection.Dialect)

   if($version -lt 3.0)
   {
     $smbServersViolatingVersion += $connection.ServerName
   }

   if (-not $connection.ContinuouslyAvailable)
   {
      $smbServersViolatingCaSupport += $connection.ServerName
   }
}

if (($smbServersViolatingVersion.length -gt 0) -or
    ($smbServersViolatingCaSupport.length -gt 0))
{
   $driveLetterToSmbMapping = Get-SmbMapping

   foreach ($driveletterMapping in $driveLetterToSmbMapping)
   {
     $validPath = ([regex]"\\\\([^\\]*)").match($driveletterMapping.remotepath)

     if ($validPath.success) 
     {
       $path = $driveletterMapping.remotepath
       $servername = $path.substring(2, $path.indexOf("\", 2)-2)

       if ($smbServersViolatingVersion -contains $servername)
       {
         $smbDriveLettersViolatingVersion += $driveletterMapping.LocalPath
       }

       if ($smbServersViolatingCaSupport -contains $servername)
       {
         $smbDriveLettersViolatingCaSupport += $driveletterMapping.LocalPath
       }
     }
   }

   $smbServersViolatingVersion        = $smbServersViolatingVersion | Sort-Object | Get-Unique
   $smbDriveLettersViolatingVersion   = $smbDriveLettersViolatingVersion | Sort-Object | Get-Unique

   $smbServersViolatingCaSupport      = $smbServersViolatingCaSupport | Sort-Object | Get-Unique
   $smbDriveLettersViolatingCaSupport = $smbDriveLettersViolatingCaSupport | Sort-Object | Get-Unique

   foreach ($vm in $discov.hyperv.vmms.virtual_machines)
   {
     $filepaths =  @()
     $filePathsViolatingVersion = ""
     $filePathsViolatingCaSupport = ""

     foreach ($diskInfo in $vm.disksInfo)
     {
       $filepaths += $diskInfo.path;
     }

     $filepaths += $vm.configurationDataRoot
     $filepaths += $vm.snapshotDataRoot
     $filepaths += $vm.swapFileDataRoot

     $filepaths = $filepaths | Get-Unique

     foreach ($path in $filepaths)
     {
       $validPath = ([regex]"\\\\([^\\]*)").match($path)
 
       if ($validPath.success) 
       {
         $servername = $path.substring(2, $path.indexOf("\", 2)-2)

         if ($smbServersViolatingVersion -contains $servername)
         {
            $filePathsViolatingVersion += "`t" + $path + "`n"
         }

         if ($smbServersViolatingCaSupport -contains $servername)
         {
            $filePathsViolatingCaSupport += "`t" + $path + "`n"
         }
       }
       else
       {
         $validPath = ([regex]"[A-Za-z]:*").match($path)

         if ($validPath.success) 
         {
           $driveLetter = $path.substring(0, 2)

           if ($smbDriveLettersViolatingVersion -contains $driveLetter)
           {
              $filePathsViolatingVersion += "`t" + $path + "`n"
           }

           if ($smbDriveLettersViolatingCaSupport -contains $driveLetter)
           {
              $filePathsViolatingCaSupport += "`t" + $path + "`n"
           }
         }
       }
     }

     if ($filePathsViolatingVersion.length -gt 0)
     {
        $smbVersionViolation += $vm.Name + " (" + $vm.guid + ") : `n" + $filePathsViolatingVersion
     }

     if ($filePathsViolatingCaSupport.length -gt 0)
     {
        $smbCaViolation += $vm.Name + " (" + $vm.guid + ") : `n" + $filePathsViolatingCaSupport
     }
   }

   if ($smbVersionViolation.length -gt 1)
   {
      RuleViolation 59 $smbVersionViolation.substring(0, $smbVersionViolation.length - 1)
   }

   if ($smbCaViolation.length -gt 1)
   {
      RuleViolation 60 $smbCaViolation.substring(0, $smbCaViolation.length - 1)
   }
}

#
# RULES 200-225: Dynamic Memory
#

# Rule 201 - Windows Server 2003 should be configured with at least the required amount memory with Dynamic Memory
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ((GetOsType $vm.ICs.kvpexchange) -eq $OSTYPE_SERVER_2003 -and
      $vm.DMEnabled -and
      (
        $vm.DMMin -lt 128 -or
        $vm.memory -lt 128 -or
        $vm.DMMax -lt 128
      ))
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 201 $ids.substring(0, $ids.length - 1)
}

# Rule 202 - Windows Server 2003 should be configured with the recommended amount memory values with Dynamic Memory
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ((GetOsType $vm.ICs.kvpexchange) -eq $OSTYPE_SERVER_2003 -and
      $vm.DMEnabled -and
      (
        $vm.DMMax -ge 128 -and
        $vm.DMMax -lt 256
      ))
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 202 $ids.substring(0, $ids.length - 1)
}

# Rule 203 - Windows Server 2008 should be configured with at least the required amount memory with Dynamic Memory
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ((GetOsType $vm.ICs.kvpexchange) -eq $OSTYPE_SERVER_2008 -and
      $vm.DMEnabled -and
      (
        $vm.DMMin -lt 256 -or
        $vm.memory -lt 512 -or
        $vm.DMMax -lt 512
      ))
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 203 $ids.substring(0, $ids.length - 1)
}

# Rule 204 - Windows Server 2008 should be configured with the recommended amount memory values with Dynamic Memory
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ((GetOsType $vm.ICs.kvpexchange) -eq $OSTYPE_SERVER_2008 -and
      $vm.DMEnabled -and
      (
        $vm.DMMax -ge 512 -and
        $vm.DMMax -lt 2048
      ))
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 204 $ids.substring(0, $ids.length - 1)
}

# Rule 205 - Windows Vista should be configured with at least the required amount memory with Dynamic Memory
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ((GetOsType $vm.ICs.kvpexchange) -eq $OSTYPE_VISTA -and
      $vm.DMEnabled -and
      (
        $vm.DMMin -lt 256 -or
        $vm.memory -lt 512 -or
        $vm.DMMax -lt 512
      ))
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 205 $ids.substring(0, $ids.length - 1)
}

# Rule 206 - Windows Vista should be configured with the recommended amount memory values with Dynamic Memory
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ((GetOsType $vm.ICs.kvpexchange) -eq $OSTYPE_VISTA -and
      $vm.DMEnabled -and
      (
        $vm.DMMax -ge 512 -and
        $vm.DMMax -lt 1024
      ))
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 206 $ids.substring(0, $ids.length - 1)
}

# Rule 207 - Windows Server 2008 R2 should be configured with at least the required amount memory with Dynamic Memory
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ((GetOsType $vm.ICs.kvpexchange) -eq $OSTYPE_SERVER_2008_R2 -and
      $vm.DMEnabled -and
      (
        $vm.DMMin -lt 256 -or
        $vm.memory -lt 512 -or
        $vm.DMMax -lt 512
      ))
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 207 $ids.substring(0, $ids.length - 1)
}

# Rule 208 - Windows Server 2008 R2 should be configured with the recommended amount memory values with Dynamic Memory
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ((GetOsType $vm.ICs.kvpexchange) -eq $OSTYPE_SERVER_2008_R2 -and
      $vm.DMEnabled -and
      (
        $vm.DMMax -ge 512 -and
        $vm.DMMax -lt 2048
      ))
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 208 $ids.substring(0, $ids.length - 1)
}

# Rule 209 - Windows 7 should be configured with at least the required amount memory with Dynamic Memory
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ((GetOsType $vm.ICs.kvpexchange) -eq $OSTYPE_7 -and
      $vm.DMEnabled -and
      (
        $vm.DMMin -lt 256 -or
        $vm.memory -lt 512 -or
        $vm.DMMax -lt 512
      ))
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 209 $ids.substring(0, $ids.length - 1)
}

# Rule 210 - Windows 7 should be configured with the recommended amount memory values with Dynamic Memory
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ((GetOsType $vm.ICs.kvpexchange) -eq $OSTYPE_7 -and
      $vm.DMEnabled -and
      (
        $vm.DMMax -ge 512 -and
        $vm.DMMax -lt 1024
      ))
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 210 $ids.substring(0, $ids.length - 1)
}

# Rule 211 - Windows OS Version 6.2 Server should be configured with at least the required amount memory with Dynamic Memory
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ((GetOsType $vm.ICs.kvpexchange) -eq $OSTYPE_SERVER_VERSION_6POINT2 -and
      $vm.DMEnabled -and
      (
        $vm.DMMin -lt 256 -or
        $vm.memory -lt 512 -or
        $vm.DMMax -lt 512
      ))
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 211 $ids.substring(0, $ids.length - 1) $discov.parent.os.Names.Windows_Server_Version_6_2
}

# Rule 212 - Windows OS Version 6.2 Server should be configured with the recommended amount memory values with Dynamic Memory
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ((GetOsType $vm.ICs.kvpexchange) -eq $OSTYPE_SERVER_VERSION_6POINT2 -and
      $vm.DMEnabled -and
      (
        $vm.DMMax -ge 512 -and
        $vm.DMMax -lt 2048
      ))
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 212 $ids.substring(0, $ids.length - 1) $discov.parent.os.Names.Windows_Server_Version_6_2
}

# Rule 213 - Windows OS Version 6.2 Client should be configured with at least the required amount memory with Dynamic Memory
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ((GetOsType $vm.ICs.kvpexchange) -eq $OSTYPE_VERSION_6POINT2 -and
      $vm.DMEnabled -and
      (
        $vm.DMMin -lt 256 -or
        $vm.memory -lt 512 -or
        $vm.DMMax -lt 512
      ))
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 213 $ids.substring(0, $ids.length - 1) $discov.parent.os.Names.Windows_Client_Version_6_2
}

# Rule 214 - Windows OS Version 6.2 Client should be configured with the recommended amount memory values with Dynamic Memory
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ((GetOsType $vm.ICs.kvpexchange) -eq $OSTYPE_VERSION_6POINT2 -and
      $vm.DMEnabled -and
      (
        $vm.DMMax -ge 512 -and
        $vm.DMMax -lt 1024
      ))
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 214 $ids.substring(0, $ids.length - 1) $discov.parent.os.Names.Windows_Client_Version_6_2
}

# Rule 215 - Dynamic Memory is enabled but not responding for some VMs
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ($vm.DMEnabled -and $vm.summaryinfo -and $vm.summaryinfo.MemoryAvailable -eq [int32]::maxvalue)
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 215 $ids.substring(0, $ids.length - 1)
}

# Rule 216 - Smart Paging Directory for the virtual machines should not be configured to be on the system disk
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ($vm.DMEnabled -and $vm.DMMin -lt $vm.memory -and 
    $vm.swapFileDataRoot.ToLower().StartsWith($discov.parent.os.SystemDrive))
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 216 $ids.substring(0, $ids.length - 1)
}

#
# RULES 226-250: Failover Replication
#

# Rule 226 - No authorization entry configured although server is enabled as recovery server
if ($cache.Msvm_ReplicationServiceSettingData.RecoveryServerEnabled -and 
   ($cache.Msvm_ReplicationAuthorizationSettingData.count -eq 0))
{
  RuleViolation 226
}


# Rule 227 - Specific authorization entries should be added when the server is enabled as recovery server
if ($cache.Msvm_ReplicationServiceSettingData.RecoveryServerEnabled -and 
   ($cache.Msvm_ReplicationAuthorizationSettingData.count -eq 1) -and
   ($cache.Msvm_ReplicationAuthorizationSettingData[0].AllowedPrimaryHostSystem -eq "*"))
{ 
  RuleViolation 227
}


# Rule 228 - Compression should be enabled for the VMs set for replication.
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if (($vm.ReplicationMode -eq $HVR_MODE_PRIMARY) -and
      ($vm.ReplicationState -ne $HVR_STATE_DISABLED) -and 
      (-not $vm.Replication.CompressionEnabled))
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 228 $ids.substring(0, $ids.length - 1)
}


# Rule 229 - Integration Services should be installed for VMs that need to be configured for Application-consistent snapshots
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if (($vm.ReplicationMode -eq $HVR_MODE_PRIMARY) -and
      ($vm.ReplicationState -ne $HVR_STATE_DISABLED) -and 
      ($vm.Replication.ApplicationConsistentSnapshotInterval -ne 0))
  {
    if ((-not $vm.ICs.vss.offered) -or 
        (($vm.state -eq $RUNNING) -and (-not $vm.ICs.vss.enabled)))
    {
      $ids += $vm.Name + " (" + $vm.guid + ")`n"
    }
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 229 $ids.substring(0, $ids.length - 1)
}


# Rule 230 - Integration Services should be installed for VMs that need to have their IP Address configured from host.
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if (($vm.ReplicationMode -eq $HVR_MODE_RECOVERY) -and
      ($vm.ReplicationState -ne $HVR_STATE_DISABLED))
  {
    if ($vm.failover_ipadresses.Length -ne 0)
    {
      if (-not $vm.ICs.kvpexchange.offered)
      {
        $ids += $vm.Name + " (" + $vm.guid + ")`n"
      }
    }
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 230 $ids.substring(0, $ids.length - 1)
}


# Rule 231 - Distinct replication tags are recommended for different authorization entries. 
$ids = ""
if ($cache.Msvm_ReplicationServiceSettingData.RecoveryServerEnabled -and 
   ($cache.Msvm_ReplicationAuthorizationSettingData.Count -gt 0))
{
  $stApsMap = @{}
  $cache.Msvm_ReplicationAuthorizationSettingData | % {
    $stApsMap[$_.TrustGroup] += @($_.AllowedPrimaryHostSystem)
  }

  $stApsMap.Keys | % {
    if ($stApsMap[$_].Length -gt 1)
    {
        $ids += $_ + " (" + ($stApsMap[$_] -join ", ") + ")`n"
    }
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 231 $ids.substring(0, $ids.length - 1)
}


# Rule 232 - Configure the Hyper-V Replica Clustering Broker resource to use the cluster as a recovery cluster.
$cluster = $null
try { $cluster = Get-Cluster -ea SilentlyContinue } catch { }
if ($cluster)
{
  if (-not($cache.FRBR_MSCluster_Resource -and 
           ($cache.FRBR_MSCluster_Resource.State -eq 2) -and
           $cache.FRBR_MSCluster_Resource.Properties["PrivateProperties"] -and
           $cache.FRBR_MSCluster_Resource.Properties["PrivateProperties"].Value -and
           $cache.FRBR_MSCluster_Resource.Properties["PrivateProperties"].Value.RecoveryServerEnabled))
  {
    RuleViolation 232
  }
}


# Rule 233 - Integrated Authentication is chosen for the virtual machines set for replication.
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if (($vm.ReplicationMode -eq $HVR_MODE_PRIMARY) -and
      ($vm.ReplicationState -ne $HVR_STATE_DISABLED))
  {
    if ($vm.Replication.AuthenticationType -eq 1)
    {
      $ids += $vm.Name + " (" + $vm.guid + ")`n"
    }
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 233 $ids.substring(0, $ids.length - 1)
}


# Rule 234 - There is no disk excluded for replication. Ensure that you create a separate virtual hard disk for Windows pagefile and exclude it.
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ($vm.ReplicationMode -eq $HVR_MODE_PRIMARY)
  {
    if ($vm.disksInfo.Count -eq $vm.Replication.IncludedDisks.Count)
    {
      $ids += $vm.Name + " (" + $vm.guid + ")`n"
    }
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 234 $ids.substring(0, $ids.length - 1)
}


# Rule 235 - Network throttling should be enabled for the network port configured to send replication traffic.
$ports = foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if (($vm.ReplicationMode -eq $HVR_MODE_PRIMARY) -and
      ($vm.ReplicationState -ne $HVR_STATE_DISABLED))
  {
        $vm.Replication.RecoveryServerPortNumber
  }
}

$netQosPolicies = Get-NetQosPolicy

$unthrottledPorts = $ports | Select -Unique | % {
    $throttled = $false
    foreach ($policy in $netQosPolicies)
    {
        if (($policy.ThrottleRateAction -gt 0) -and
            ($policy.IPDstPortStart -le $_) -and
            ($policy.IPDstPortEnd -ge $_))
        {
            $throttled = $true
        }
    }
    if(!$throttled)
    {
        $_
    }
}
if ($unthrottledPorts)
{
  RuleViolation 235 ($unthrottledPorts -join "`n")
}


# Rule 236 - Failover IP Address settings haven’t been configured for the recovery VM.
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if (($vm.ReplicationMode -eq $HVR_MODE_RECOVERY) -and
      ($vm.ReplicationState -ne $HVR_STATE_DISABLED))
  {
    if ($vm.failover_ipadresses.Length -eq 0)
    {
      $ids += $vm.Name + " (" + $vm.guid + ")`n"
    }
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 236 $ids.substring(0, $ids.length - 1)
}


# Rule 237 - Resynchronization of replication should be scheduled for off-peak hours.
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if (($vm.ReplicationMode -eq $HVR_MODE_PRIMARY) -and
      ($vm.ReplicationState -ne $HVR_STATE_DISABLED))
  {
    $interval = New-TimeSpan -Days 0
    if ($vm.Replication.AutoResynchronizeEnabled)
    {
      $intervalStart = [Management.ManagementDateTimeconverter]::ToTimeSpan($vm.Replication.AutoResynchronizeIntervalStart)
      $intervalEnd = [Management.ManagementDateTimeconverter]::ToTimeSpan($vm.Replication.AutoResynchronizeIntervalEnd)
      $interval = $intervalEnd - $intervalStart
      if ($intervalEnd -lt $intervalStart)
      {
        $interval += New-TimeSpan -Days 1 
      }
    }

    if ((-not $vm.Replication.AutoResynchronizeEnabled) -or
        ($interval -gt (New-TimeSpan -Hours 12)))
    {
      $ids += $vm.Name + " (" + $vm.guid + ")`n"
    }
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 237 $ids.substring(0, $ids.length - 1)
}


# Rule 238 - All nodes on the cluster don’t have the required certificate.
$cluster = $null
try { $cluster = Get-Cluster -ea SilentlyContinue } catch { }
if ($cluster)
{
  if ($cache.FRBR_MSCluster_Resource -and
      $cache.FRBR_MSCluster_Resource.Properties["PrivateProperties"])
  {
    $frbrProps = $cache.FRBR_MSCluster_Resource.Properties["PrivateProperties"].Value
    if ($frbrProps.RecoveryServerEnabled -and $frbrProps.CertificateThumbPrint)
    {
      # Cluster scenario.
      $capName = $cache.FRBR_MSCluster_Resource.GetDependencies($false).Expression.Split(@('[', ']'))[1]
      $capFQDN = "{0}.{1}" -f $capName, $cluster.Domain
      $brokerThumbprint = $frbrProps.CertificateThumbPrint

      $nodes = Get-ClusterNode  | % { "{0}.{1}" -f $_.Name, $cluster.Domain }
      $nodesWithoutCert = $nodes | % {

        # Find matching broker cert.
        $computernameFQDN = $_
        $sigInfoFQDN = $capFQDN
        $matchingBrokerCerts = @(GetMatchingCerts $computernameFQDN $brokerThumbprint $sigInfoFQDN)

        # get node's thumbprint
        $nodefrssd = gwmi -n $V2_NS Msvm_ReplicationServiceSettingData -ComputerName $_
        $nodeThumbprint = $nodefrssd.CertificateThumbprint
        # Find matching server cert.
        $computernameFQDN = $_
        $sigInfoFQDN = $computernameFQDN
        $matchingServerCerts = @(GetMatchingCerts $computernameFQDN $nodeThumbprint $sigInfoFQDN)

        if (($matchingServerCerts.Length -eq 0) -or ($matchingBrokerCerts.Length -eq 0))
        {
          $_
        }
      }
    }
  }
}
else
{
  $frssd = $cache.Msvm_ReplicationServiceSettingData
  if ($frssd.RecoveryServerEnabled -and $frssd.CertificateThumbPrint)
  {
    # Non-Cluster scenario.
    $ipProps = [System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties()
    $computernameFQDN = "{0}.{1}" -f $ipProps.HostName, $ipProps.DomainName

    $thumbprint = $frssd.CertificateThumbPrint
    $sigInfoFQDN = $computernameFQDN
    $nodesWithoutCert = $computernameFQDN | % {
      $matchingServerCerts = @(GetMatchingCerts $computernameFQDN $thumbprint $sigInfoFQDN)
      if ($matchingServerCerts.Length -eq 0)
      {
        $_
      }
    }
  }
}

if ($nodesWithoutCert)
{
  RuleViolation 238 ($nodesWithoutCert -join "`n")
}


# Rule 239 - Avoid pausing replication of a Virtual Machine.
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if (($vm.ReplicationMode -eq $HVR_MODE_PRIMARY) -and
      ($vm.ReplicationState -eq $HVR_STATE_PAUSED))
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 239 $ids.substring(0, $ids.length - 1)
}


# Rule 240 - Test failover must be done after Initial Replication is completed.
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if (($vm.ReplicationMode -eq $HVR_MODE_RECOVERY) -and
      ($vm.ReplicationState -gt $HVR_STATE_WAITINGFORIRCOMPLETE))
  {
    if ($vm.ReplicationProperties.LastTestFailoverTime -eq (New-Object DateTime 1601, 1, 1))
    {
      $ids += $vm.Name + " (" + $vm.guid + ")`n"
    }
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 240 $ids.substring(0, $ids.length - 1)
}


# Rule 241 - Test failover has not be done in the past 1 month.
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if (($vm.ReplicationMode -eq $HVR_MODE_RECOVERY) -and
      ($vm.ReplicationState -ne $HVR_STATE_WAITINGFORIRCOMPLETE))
  {
    if (($vm.ReplicationProperties.LastTestFailoverTime -ne (New-Object DateTime 1601, 1, 1)) -and
        ($vm.ReplicationProperties.LastTestFailoverTime -le [DateTime]::UtcNow.AddMonths(-1)))
    {
      $ids += $vm.Name + " (" + $vm.guid + ")`n"
    }
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 241 $ids.substring(0, $ids.length - 1)
}

# Rule 244 - VHDX disks are recommended for virtual machines that have recovery history enabled in replication settings
$ids = ""
$vmNameIdMap = @{}
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if (($vm.ReplicationMode -eq $HVR_MODE_PRIMARY) -and
      ($vm.ReplicationState -ne $HVR_STATE_DISABLED) -and
      ($vm.Replication.RecoveryHistory -gt 0))
  {
    $vm.Replication.IncludedDisks | % { 
      if ((([wmi]$_).HostResource.Count -ne 1) -or 
          ([IO.Path]::GetExtension(([wmi]$_).HostResource[0]) -ine ".VHDX"))
      {
        $vmNameIdMap[$vm.Name] = $vm.guid
      }
    }
  }
}
$vmNameIdMap.Keys | % {
  $ids += $_ + " (" + $vmNameIdMap[$_] + ")`n"
}

if ($ids.length -gt 1)
{
  RuleViolation 244 $ids.substring(0, $ids.length - 1) $discov.parent.os.Names.Windows_Short
}


# 245 - Recovery snapshots should be removed after failover
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if (($vm.ReplicationMode -eq $HVR_MODE_RECOVERY) -and
      ($vm.ReplicationState -eq $HVR_STATE_RECOVERYRECOVERED))
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 245 $ids.substring(0, $ids.length - 1)
}

#
# RULES 251-299: Clustering and Live Migration
#

# Rule 251 - Live Migration network speed is less than 1Gbps
$migrationCount = GetAllowedConcurrentMigrationCount
if ($migrationCount -gt 0)
{
  $physicalNics = $cache.MigrationPhysicalListeningNicList
  
  $anyNicIsAtLeast1Gb = $false
  
  foreach ($nic in $physicalNics)
  {
    if ($nic.Speed -ge 1000000000)
    {
      $anyNicIsAtLeast1Gb = $true
      break
    }
  }
  
  if (-not $anyNicIsAtLeast1Gb)
  {
    RuleViolation 251
  }
}


# Rule 252 - Some networks for Live Migration have speed less than 1Gbps
$migrationCount = GetAllowedConcurrentMigrationCount
if ($migrationCount -gt 0)
{
  $physicalNics = $cache.MigrationPhysicalListeningNicList
  
  $anyNicIsBelow1Gb = $false
  $anyNicIsAtLeast1Gb = $false
  
  foreach ($nic in $physicalNics)
  {
    if ($nic.Speed -lt 1000000000)
    {
      $anyNicIsBelow1Gb = $true
    }
    else
    {
      $anyNicIsAtLeast1Gb = $true
    }
  }
  
  if ($anyNicIsBelow1Gb -and $anyNicIsAtLeast1Gb)
  {
    RuleViolation 252
  }
}

#
# RULES 300-325: Backup
#

# Rule 300 - The system has not been backed up in the last week

$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ($vm.lastSuccessfulBackupTime)
  {
    # The VM has been successfully backed up at least once
    $lastSuccessfulBackupTime = [system.management.managementdatetimeconverter]::ToDateTime($vm.lastSuccessfulBackupTime)
  }
  else
  {
    # The VM has never been successfully backed up. Use the VM creation time instead.
    $lastSuccessfulBackupTime = [system.management.managementdatetimeconverter]::ToDateTime($vm.creationTime)
  }

  $now = [DateTime]::Now
  $daysSinceLastSuccessfulBackup = ($now - $lastSuccessfulBackupTime).Days

  if ($daysSinceLastSuccessfulBackup -gt 7)
  {
    $ids += $vm.name + " (" + $vm.guid + ")`n"
  }	
}
if ($ids.length -gt 1)
{
  RuleViolation 300 $ids.substring(0, $ids.length - 1)
}

#
# RULES 326-350: Storage Migration
#


#
# RULES 351-375: VHD/VHDX
#

# Rule 351 - Dynamic VHD/VHDX disks are not recommended for production environment
# Rule 354 - Dynamic VHDs can cause disk corruption on power failures

$rule351 = ""
$rule354 = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  foreach ($diskInfo in $vm.disksInfo)
  {
    if ($diskInfo.type -eq 3)
    {
      if (($diskInfo.format -eq $STORAGE_FORMAT_VHD -or
           $diskInfo.format -eq $STORAGE_FORMAT_VHDX))
      {
        $rule351 += $vm.Name + " (" + $vm.guid + ") - " + $diskInfo.path + "`n"
      }

      if ($diskInfo.format -eq $STORAGE_FORMAT_VHD)
      {
        $rule354 += $vm.Name + " (" + $vm.guid + ") - " + $diskInfo.path + "`n"
      }
    }
  }
}

if ($rule351.length -gt 1)
{
  RuleViolation 351 $rule351.substring(0, $rule351.length - 1)
}

if ($rule354.length -gt 1)
{
  RuleViolation 354 $rule354.substring(0, $rule354.length - 1) $discov.parent.os.Names.Windows_Short
}


# Rule 352 - Differencing VHD/VHDX disks are not recommended for production environment
# Rule 355 - Differencing VHDs can cause disk corruption on power failures

$rule352 = ""
$rule355 = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if(-not [bool]$vm.full_snap_count)
  {
    foreach ($diskInfo in $vm.disksInfo)
    {
      if($diskInfo.type -eq 4)
      {
        if (($diskInfo.format -eq $STORAGE_FORMAT_VHD -or
             $diskInfo.format -eq $STORAGE_FORMAT_VHDX))
        {
          $rule352 += $vm.Name + " (" + $vm.guid + ") - " + $diskInfo.path + "`n"
        }

        if ($diskInfo.format -eq $STORAGE_FORMAT_VHD)
        {
          $rule355 += $vm.Name + " (" + $vm.guid + ") - " + $diskInfo.path + "`n"
        }
      }
    }
  }
}

if ($rule352.length -gt 1)
{
  RuleViolation 352 $rule352.substring(0, $rule352.length - 1)
}

if ($rule355.length -gt 1)
{
  RuleViolation 355 $rule355.substring(0, $rule355.length - 1) $discov.parent.os.Names.Windows_Short
}

# Rule 353 - A dynamic or differencing disk might have performance issues due to sub-optimal alignment between virtual blocks and physical disk sectors
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  foreach ($diskInfo in $vm.disksInfo)
  {
    if ($diskInfo.format -eq $STORAGE_FORMAT_VHD)
    {
      if ($diskInfo.is4kAligned -eq 0 -and $diskInfo.PhysicalDiskSectorSize -eq 4096)
      {
        $ids += $vm.Name + " (" + $vm.guid + ") - " + $diskInfo.path + "`n"
      }
    }
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 353 $ids.substring(0, $ids.length - 1)
}

#
# RULES 401-425: IOV
#

# Rule 401 - Some IOV Virtual Functions are not being utilized
$ids=""
if ($discov.parent.networking.SupportsIov -eq $true)
{
  foreach ($vm in $discov.hyperv.vmms.virtual_machines)
  {
    if ($vm.runningCurrently -eq $false -or
        $vm.OSsupportsIOV -eq $false)
    {
      continue
    }
  
    foreach ($connection in $vm.connections)
    {
      if ($connection.IOVOffloadWeight -gt 0)
      {
        continue
      }
      
      if ($connection.pool -ne $null)
      {
        if ($connection.pool.VFOffloads -lt $connection.pool.MaxIOVOffloads)
        {
          $ids += $vm.name + " (" + $vm.guid + ")`n"
          break      
        }
        continue
      }
      # If IOVPreferred is false, then either there is no corresponding switch
      # or the switch is not IOV-Enabled
      if ($connection.switch.IOVPreferred -eq $true -and
          $connection.switch.IOVSupported -eq $true -and
          $connection.switch.VFOffloads -lt $connection.switch.MaxIOVOffloads)
      {
        $ids += $vm.name + " (" + $vm.guid + ")`n"
        break
      }
    }
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 401 $ids.substring(0, $ids.length - 1)
}

# Rule 402 - There are not enough Virtual Functions available to satisfy all virtual machines
$ids=""
if ($discov.parent.networking.SupportsIov -eq $true)
{
  foreach ($vm in $discov.hyperv.vmms.virtual_machines)
  {
    if ($vm.runningCurrently -eq $false -or
        $vm.OSsupportsIOV -eq $false)
    {
      continue
    }
  
    foreach ($connection in $vm.connections)
    {
      if ($connection.IOVOffloadWeight -eq 0 -or 
          $connection.portIOVOffloadUsage -gt 0)
      {
        continue
      }

      if ($connection.pool -ne $null)
      {
        if ($connection.pool.VFOffloads -eq $connection.pool.MaxIOVOffloads)
        {
          $ids += $vm.name + " (" + $vm.guid + ")`n"
          break      
        }
        continue
      }
      # If IOVPreferred is false, then either there is no corresponding switch
      # or the switch is not IOV-Enabled
      if($connection.switch.IOVPreferred -eq $true -and
         $connection.switch.IOVSupported -eq $true -and
         $connection.switch.VFOffloads -eq $connection.switch.MaxIOVOffloads)
      {
        $ids += $vm.name + " (" + $vm.guid + ")`n"
        break 
      }
    }
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 402 $ids.substring(0, $ids.length - 1)
}

# Rule 403 - One or more virtual machines operating systems do not support IOV
$ids = ""
if ($discov.parent.networking.SupportsIov -eq $true)
{
  foreach ($vm in $discov.hyperv.vmms.virtual_machines)
  {
    if ($vm.runningCurrently -eq $false -or
        $vm.OSsupportsIOV -eq $true)
    {
      continue
    }
  
    foreach ($connection in $vm.connections)
    {
      if ($connection.IOVOffloadWeight -eq 0)
      {
        continue
      }
      # If IOVPreferred is false, then either there is no corresponding switch
      # or the switch is not IOV-Enabled
      if($connection.switch.IOVPreferred -eq $true -and
         $connection.switch.IOVSupported -eq $true)
      {
        $ids += $vm.Name + " (" + $vm.guid + ")`n"
        break 
      }
    }
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 403 $ids.substring(0, $ids.length - 1)
}

# Rule 404 - One or more virtual machines are not using their IOV virtual functions
$ids=""
if ($discov.parent.networking.SupportsIov -eq $true)
{
  foreach ($vm in $discov.hyperv.vmms.virtual_machines)
  {
    if ($vm.runningCurrently -eq $false -or
        $vm.OSsupportsIOV -eq $false)
    {
      continue
    }
  
    foreach ($connection in $vm.connections)
    {
      if ($connection.IOVOffloadWeight -eq 0)
      {
        continue
      }
      # If IOVPreferred is false, then either there is no corresponding switch
      # or the switch is not IOV-Enabled
      if($connection.switch.IOVPreferred -eq $true -and
         $connection.portIOVOffloadUsage -ne 0 -and
         $connection.portIovVfDataPathActive -eq $false)
      {
        $ids += $vm.name + " (" + $vm.guid + ")`n"
        break
      }
    }
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 404 $ids.substring(0, $ids.length - 1)
}

#
# RULES 426-475: Networking
#

# Rule 426 - Should have at least MAC_RANGE MAC Addresses in available range
if ($discov.parent.networking.MACrange -lt $MAC_RANGE)
{
  RuleViolation 426
}

# Rule 427 - Should have more than one NIC
if ($discov.hyperv.vmms.running)
{
  if (@($cache.MSFT_NetAdapter | ?{$_.Virtual -eq $false}).Count -lt 2)
  {
    RuleViolation 427
  }
}

# Rule 429 - vSwitches should not be disabled
$ids = ""
foreach ($vswitch in $discov.parent.networking.vSwitches)
{
  if (-not $vswitch.enabled -and $vswitch.SharedWithHost)
  {
    $ids += $vswitch.description + "`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 429 $ids.substring(0, $ids.length - 1)
}

# Rule 430 - Network Adapters should be enabled
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ($vm.ICs.heartbeat.enabled -and
      -not $vm.network_enabled -and
      $vm.network_enabled -ne $null)
  {
    $ids += $vm.name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 430 $ids.substring(0, $ids.length - 1)
}

# Rule 431 - Windows Server 2003 x64 and Windows XP x64 cannot use legacy NIC
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ($vm.ICs.kvpexchange.guestintrinsic -and
      $vm.ICs.kvpexchange.guestintrinsic.OSVersion -like "5.2*" -and
      $vm.ICs.kvpexchange.guestintrinsic.ProcessorArchitecture -ne 0 -and
      $vm.legacy_network)
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 431 $ids.substring(0, $ids.length - 1)
}

# Rule 432 - Should not use Legacy NIC in supported OS
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ($vm.ICs.kvpexchange.guestintrinsic -and
      $vm.legacy_network)
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 432 $ids.substring(0, $ids.length - 1)
}

# Rule 433 - One or more mandatory virtual switch extensions
# are not available
$ids = (VerifyVmMMandatoryVirtualSwitchExtensionsAreAvailable)
if ($ids.length -gt 1)
{
  RuleViolation 433 $ids.substring(0, $ids.length - 1)
}

# Rule 434 - A team bound to a virtual switch should only have one exposed team interface 
$ids = ""
foreach ($vswitch in $discov.parent.networking.vSwitches)
{
  if ($vswitch.numsiblingtnics -gt 1)
  {
    $ids += $vswitch.description + "`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 434 $ids.substring(0, $ids.length - 1)
}

# Rule 435 - The team interface bound to a virtual switch should be in default mode
$ids = ""
foreach ($vswitch in $discov.parent.networking.vSwitches)
{
  if ($vswitch.tnicDefaultMode -eq $false)
  {
    $ids += $vswitch.description + "`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 435 $ids.substring(0, $ids.length - 1)
}

# Rule 436 - VMQ is not enabled on the network adapter bound to an external virtual switch
$ids = ""
foreach ($vswitch in $discov.parent.networking.vSwitches)
{
  if ($vswitch.VmqEnabled -eq $false)
  {
    $ids += $vswitch.description + "`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 436 $ids.substring(0, $ids.length - 1)
}

# Rule 437 - One or more network adapters should be configured as
# the destination for Port Mirroring
$ids = ""
foreach ($vswitch in $discov.parent.networking.vSwitches)
{
  $map = $discov.parent.networking.switchMap[$vswitch.guid]
  
  if ($map -ne $null -and
      $map.SourceMirrors -ne $null -and
      $map.DestinationMirrors -ne $null)
  {
    if ($map.SourceMirrors.Count -gt 0 -and
        $map.DestinationMirrors.Count -eq 0)
    {
      $ids += "'" + $vSwitch.description + "':`n"
      foreach ($str in $map.SourceMirrors.keys)
      {
        $ids += $str + "`n"
      }
    }
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 437 $ids.substring(0, $ids.length - 1)
}

# Rule 438 - One or more network adapters should be configured as 
# the source for Port Mirroring
$ids = ""
foreach ($vswitch in $discov.parent.networking.vSwitches)
{
  $map = $discov.parent.networking.switchMap[$vswitch.guid]
  
  if ($map -ne $null -and
      $map.SourceMirrors -ne $null -and
      $map.DestinationMirrors -ne $null)
  {
    if ($map.SourceMirrors.Count -eq 0 -and
        $map.DestinationMirrors.Count -gt 0)
    {
      $ids += "'" + $vSwitch.description + "':`n"
      foreach ($str in $map.SourceMirrors.keys)
      {
        $ids += $str + "`n"
      }
    }
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 438 $ids.substring(0, $ids.length - 1)
}

# Rule 439 - PVLAN configuration on a virtual switch must be consistent
#
# Error Code Table
# 1 - Access VLAN also configured as Private VLAN
# 2 - Primary VLAN also configured as Access VLAN
# 3 - Secondary VLAN also configured as Access VLAN
# 4 - Secondary VLAN also configured as Primary VLAN
# 5 - Primary VLAN also configured as Secondary VLAN
# 6 - Secondary VLAN configured both as Isolated and as Community
# 7 - Secondary VLAN mapped to multiple Primary VLANs
# 8 - More isolated VLANs configured than necessary

$ids = ""
$allVnics = $cache.Msvm_EthernetSwitchPortVlanSettingData
$accessVLANs = @()
$primaryVLANs = @()
$isolatedVLANs = @()
$communityVLANs = @()
$secondaryVLANs = @()
$secondaryToPrimaryMap = @{}

# Declaration of Operation modes
$accessMode = 1
$privateMode = 3

# Declaration of PvlanModes
$isolatedMode = 1
$communityMode = 2
$promiscuousMode = 3

foreach ($nic in $allVnics)
{
  if ($nic.InstanceId.StartsWith("Microsoft:Definition"))
  {
    continue
  }
  
  $vmGuid = $nic.InstanceId.Substring(10, 36)
  $currentVmCache = $vmCache[$vmGuid]
  
  if ($currentVmCache -ne $null -and
      $currentVmCache["Msvm_ComputerSystem"].EnabledState -ne $RUNNING)
  {
    # If the VM is not running, don't process the VLAN FSD.
    continue
  }
  
  if ($nic.OperationMode -eq $accessMode)
  {
    if (($primaryVLANs -contains $nic.AccessVlanId) -or
        ($isolatedVLANs -contains $nic.AccessVlanId) -or
        ($communityVLANs -contains $nic.AccessVlanId) -or
        ($secondaryVLANs -contains $nic.AccessVlanId))
    {
      $ids = "1"
      break
    }
    
    if ($accessVLANs -notcontains $nic.AccessVlanId)
    {
      $accessVLANs += $nic.AccessVlanId 
    }
  }
  elseif (($nic.OperationMode -eq $privateMode) -and 
          ($nic.PvlanMode -eq $isolatedMode -or
           $nic.PvlanMode -eq $communityMode))
  {
    if ($accessVLANs -contains $nic.PrimaryVlanId)
    {
      $ids = "2"
      break
    }    
    if ($accessVLANs -contains $nic.SecondaryVlanId)
    {
      $ids = "3"
      break
    }
    if ($primaryVLANs -contains $nic.SecondaryVlanId)
    {
      $ids = "4"
      break
    }
    if (($isolatedVLANs -contains $nic.PrimaryVlanId) -or
        ($communityVLANs -contains $nic.PrimaryVlanId) -or
        ($secondaryVLANs -contains $nic.PrimaryVlanId))
    {
      $ids = "5"
      break
    }
    if (($isolatedVLANs -contains $nic.SecondaryVlanId -and
         $nic.PvlanMode -eq $communityMode) -or
        ($communityVLANs -contains $nic.SecondaryVlanId -and
         $nic.PvlanMode -eq $isolatedMode))
    {
      $ids = "6"
      break
    }
    
    if ($secondaryToPrimaryMap[$nic.SecondaryVlanId] -eq $null)
    {
      $secondaryToPrimaryMap.add($nic.SecondaryVlanId, $nic.PrimaryVlanId)
    }
    elseif ($secondaryToPrimaryMap[$nic.SecondaryVlanId] -ne `
            $nic.PrimaryVlanId)
    {
      $ids = "7"
      break
    }
    
    if ($primaryVLANs -notcontains $nic.PrimaryVlanId)
    {    
      $primaryVLANs += $nic.PrimaryVlanId
    }
    if (($nic.PvlanMode -eq $isolatedMode) -and
        ($isolatedVLANs -notcontains $nic.SecondaryVlanId))
    {
      $isolatedVLANs += $nic.SecondaryVlanId
    }
    if (($nic.PvlanMode -eq $communityMode) -and
        ($communityVLANs -notcontains $nic.SecondaryVlanId))
    {
      $communityVLANs += $nic.SecondaryVlanId
    }
  }
  elseif (($nic.OperationMode -eq $privateMode) -and
          ($nic.PvlanMode -eq $promiscuousMode))
  {
    if ($accessVLANs -contains $nic.PrimaryVlanId)
    {
      $ids = "2"
      break
    }
    if (($isolatedVLANs -contains $nic.PrimaryVlanId) -or
        ($communityVLANs -contains $nic.PrimaryVlanId) -or
        ($secondaryVLANs -contains $nic.PrimaryVlanId))
    {
      $ids = "5"
      break
    }
    foreach ($vlan in $nic.SecondaryVlanIdList)
    {
      if ($accessVLANs -contains $vlan)
      {
        $ids = "3"
        break
      }
      if ($primaryVLANs -contains $vlan)
      {
        $ids = "4"
        break
      }
      if ($secondaryToPrimaryMap[$vlan] -eq $null)
      {
        $secondarytoPrimaryMap.add($vlan, $nic.PrimaryVlanId)
      }
      elseif ($secondaryToPrimaryMap[$vlan] -ne $nic.PrimaryVlanId)
      {
        $ids = "7"
        break
      }
      
      # We don't know the type of the secondary VLANs (Isolated vs Community)
      # that are configured for promiscuous ports. So keep a separate list to
      # track them
      if ($secondaryVLANs -notcontains $vlan)
      {
        $secondaryVLANs += $vlan
      }
    }
    
    if ($ids.length -gt 0)
    {
      break
    }
    
    if ($primaryVLANs -notcontains $nic.PrimaryVlanId)
    {    
      $primaryVLANs += $nic.PrimaryVlanId
    }
  }
}

# Report one violation at a time (consistent with the logics above)
if ($ids.length -eq 0)
{
  # The relationship between Isolated VLAN and Primary VLAN is 0,1 to 1. 
  # So there can't be more Isolated VLANs than Primary VLANs
  if ($isolatedVLANs.length -gt $primaryVLANs.length)
  {
    $ids = "8"
  }
}
if ($ids.length -gt 0)
{
  RuleViolation 439 $ids
}

# Rule 440 - The Windows Filtering Platform (WFP) virtual switch extension should be 
#            enabled if it is required by third party extensions.
$ids = ""
foreach ($vswitch in $discov.parent.networking.vSwitches)
{
  if ($vswitch.wfpExtension -eq $null -or
      $vswitch.wfpExtension.EnabledState -ne 2)
  {
    $ids += $vSwitch.description + "`n"
  }
}

if ($ids.length -gt 1)
{
  RuleViolation 440 $ids.substring(0, $ids.length - 1)
}

#
# RULES 476-499: Synthetic Fibre Channel
#

# Rule 476
# Every Virtual SAN must be connected to a Physical HBA
$ids = ""

foreach ($FCresourcepool in $discov.parent.SynthFCPools)
{
  if ($FCresourcepool.IsAssignedHBA -eq $false)
  {
    $ids += $FCresourcepool.PoolID + " (" + $FCresourcepool.instanceID + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 476 $ids.substring(0, $ids.length - 1)
}

# Rule 477
# Every VM should be connected to at least two Virtual HBAs (If any)
$ids=""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ($vm.SynthFCRASD -ne $null -and 
      $vm.SynthFCRASD.Count -eq 1)
  {
    $ids += $vm.name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 477 $ids.substring(0, $ids.length - 1)
}

# Rule 478
# A VM should not be configured to allow reduced FC redundancy while live migration
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ($vm.reducedfcredundancy)
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 478 $ids.substring(0, $ids.length - 1)
}

#
# RULES 500-550: Guest support matrix
#

# Rule 500 - Windows Server 2003 should have max 2 processors
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ((GetOsType $vm.ICs.kvpexchange) -eq $OSTYPE_SERVER_2003 -and
      $vm.processor_count -gt 2)
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 500 $ids.substring(0, $ids.length - 1)
}

# Rule 502 - Windows Vista should have max 2 processors
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ((GetOsType $vm.ICs.kvpexchange) -eq $OSTYPE_VISTA -and
      $vm.processor_count -gt 2)
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 502 $ids.substring(0, $ids.length - 1)
}

# Rule 503 - Windows XP SP2 x86 should have at most 1 processor
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ((GetOsType $vm.ICs.kvpexchange) -eq $OSTYPE_XP -and
      [int]$vm.ICs.kvpexchange.guestintrinsic.ServicePackMajor -le 2 -and
      [int]$vm.ICs.kvpexchange.guestintrinsic.ProcessorArchitecture -eq 0 -and
      $vm.processor_count -gt 1)
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 503 $ids.substring(0, $ids.length - 1)
}

# Rule 504 - Windows XP SP3 x86 should have at most 2 processors
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ((GetOsType $vm.ICs.kvpexchange) -eq $OSTYPE_XP -and
      [int]$vm.ICs.kvpexchange.guestintrinsic.ServicePackMajor -eq 3 -and
      [int]$vm.ICs.kvpexchange.guestintrinsic.ProcessorArchitecture -eq 0 -and
      $vm.processor_count -gt 2)
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 504 $ids.substring(0, $ids.length - 1)
}

# Rule 505 - Windows XP SP2 x64 should have at most 2 processors
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ((GetOsType $vm.ICs.kvpexchange) -eq $OSTYPE_XP -and
      [int]$vm.ICs.kvpexchange.guestintrinsic.ServicePackMajor -le 2 -and
      [int]$vm.ICs.kvpexchange.guestintrinsic.ProcessorArchitecture -ne 0 -and
      $vm.processor_count -gt 2)
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 505 $ids.substring(0, $ids.length - 1)
}

# Rule 506 - Windows 7 should have at most 4 processors
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ((GetOsType $vm.ICs.kvpexchange) -eq $OSTYPE_7 -and
      $vm.processor_count -gt 4)
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 506 $ids.substring(0, $ids.length - 1)
}

# Rule 508 - Windows XP must have at least 64 MB of RAM
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ((GetOsType $vm.ICs.kvpexchange) -eq $OSTYPE_XP -and
      $vm.memory -lt 64 -and !$vm.DMEnabled)
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 508 $ids.substring(0, $ids.length - 1)
}

# Rule 509 - Windows XP should have at least 128 MB of RAM
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ((GetOsType $vm.ICs.kvpexchange) -eq $OSTYPE_XP -and
      $vm.memory -lt 128 -and $vm.memory -ge 64 -and !$vm.DMEnabled)
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 509 $ids.substring(0, $ids.length - 1)
}

# Rule 512 - Windows Server 2003 must have at least 128 MB of RAM
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ((GetOsType $vm.ICs.kvpexchange) -eq $OSTYPE_SERVER_2003 -and
      $vm.memory -lt 128 -and !$vm.DMEnabled)
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 512 $ids.substring(0, $ids.length - 1)
}

# Rule 513 - Windows Server 2003 should have at least 256 MB of RAM
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ((GetOsType $vm.ICs.kvpexchange) -eq $OSTYPE_SERVER_2003 -and
      $vm.memory -lt 256 -and $vm.memory -ge 128 -and !$vm.DMEnabled)
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 513 $ids.substring(0, $ids.length - 1)
}

# Rule 514 - Windows Vista must have at least 512 MB of RAM
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ((GetOsType $vm.ICs.kvpexchange) -eq $OSTYPE_VISTA -and
      $vm.memory -lt 512 -and !$vm.DMEnabled)
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 514 $ids.substring(0, $ids.length - 1)
}

# Rule 515 - Windows Vista should have at least 1 GB of RAM
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ((GetOsType $vm.ICs.kvpexchange) -eq $OSTYPE_VISTA -and
      $vm.memory -lt 1024 -and $vm.memory -ge 512 -and !$vm.DMEnabled)
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 515 $ids.substring(0, $ids.length - 1)
}

# Rule 516 - Windows Server 2008 must have at least 512 MB of RAM
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ((GetOsType $vm.ICs.kvpexchange) -eq $OSTYPE_SERVER_2008 -and
      $vm.memory -lt 512 -and !$vm.DMEnabled)
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 516 $ids.substring(0, $ids.length - 1)
}

# Rule 517 - Windows Server 2008 should have at least 2 GB of RAM
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ((GetOsType $vm.ICs.kvpexchange) -eq $OSTYPE_SERVER_2008 -and
      $vm.memory -lt 2048 -and $vm.memory -ge 512 -and !$vm.DMEnabled)
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 517 $ids.substring(0, $ids.length - 1)
}

# Rule 518 - Windows Server 2008 R2 must have at least 512 MB of RAM
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ((GetOsType $vm.ICs.kvpexchange) -eq $OSTYPE_SERVER_2008_R2 -and
      $vm.memory -lt 512 -and !$vm.DMEnabled)
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 518 $ids.substring(0, $ids.length - 1)
}

# Rule 519 - Windows Server 2008 R2 should have at least 2 GB of RAM
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ((GetOsType $vm.ICs.kvpexchange) -eq $OSTYPE_SERVER_2008_R2 -and
      $vm.memory -lt 2048 -and $vm.memory -ge 512 -and !$vm.DMEnabled)
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 519 $ids.substring(0, $ids.length - 1)
}

# Rule 520 - Windows 7 must have at least 512 MB of RAM
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ((GetOsType $vm.ICs.kvpexchange) -eq $OSTYPE_7 -and
      $vm.memory -lt 512 -and !$vm.DMEnabled)
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 520 $ids.substring(0, $ids.length - 1)
}

# Rule 521 - Windows 7 should have at least 1 GB of RAM
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ((GetOsType $vm.ICs.kvpexchange) -eq $OSTYPE_7 -and
      $vm.memory -lt 1024 -and $vm.memory -ge 512 -and !$vm.DMEnabled)
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 521 $ids.substring(0, $ids.length - 1)
}

# Rule 522 - Windows OS Version 6.2 Server should be configured with at least the minimum amount of memory
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ((GetOsType $vm.ICs.kvpexchange) -eq $OSTYPE_SERVER_VERSION_6POINT2 -and
      $vm.memory -lt 512 -and !$vm.DMEnabled)
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 522 $ids.substring(0, $ids.length - 1) $discov.parent.os.Names.Windows_Server_Version_6_2
}

# Rule 523 - Windows OS Version 6.2 Server should be configured with the recommended amount of memory
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ((GetOsType $vm.ICs.kvpexchange) -eq $OSTYPE_SERVER_VERSION_6POINT2 -and
      $vm.memory -lt 2048 -and $vm.memory -ge 512 -and !$vm.DMEnabled)
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 523 $ids.substring(0, $ids.length - 1) $discov.parent.os.Names.Windows_Server_Version_6_2
}

# Rule 524 - Windows OS Version 6.2 Client should be configured with at least the minimum amount of memory
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ((GetOsType $vm.ICs.kvpexchange) -eq $OSTYPE_VERSION_6POINT2 -and
      $vm.memory -lt 512 -and !$vm.DMEnabled)
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 524 $ids.substring(0, $ids.length - 1) $discov.parent.os.Names.Windows_Client_Version_6_2
}

# Rule 525 - Windows OS Version 6.2 Client should be configured with the recommended amount of memory
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ((GetOsType $vm.ICs.kvpexchange) -eq $OSTYPE_VERSION_6POINT2 -and
      $vm.memory -lt 1024 -and $vm.memory -ge 512 -and !$vm.DMEnabled)
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 525 $ids.substring(0, $ids.length - 1) $discov.parent.os.Names.Windows_Client_Version_6_2
}

#
# RULES 551-575: Recovery Snapshots
#


#
# RULES 576-599: Normal Snapshots
#

# Rule 576 - Snapshots are not recommended
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ($vm.snap_count)
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 576 $ids.substring(0, $ids.length - 1)
}


#
# RULES 600-624: Storage
#

# Rule 600 - Windows versions that support SCSI should have SCSI
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ($vm.ICs.kvpexchange.guestintrinsic -and
      ($vm.ICs.kvpexchange.guestintrinsic.OSMajorVersion -ne 5 -or
      $vm.ICs.kvpexchange.guestintrinsic.OSMinorVersion -gt 1) -and
      $vm.scsi_enabled -eq $null)
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 600 $ids.substring(0, $ids.length - 1)
}

# Rule 601 - Windows versions that do not support SCSI should not have SCSI
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ($vm.ICs.kvpexchange.guestintrinsic -and
      $vm.ICs.kvpexchange.guestintrinsic.OSMajorVersion -eq 5 -and
      $vm.ICs.kvpexchange.guestintrinsic.OSMinorVersion -le 1 -and
      $vm.scsi_enabled -ne $null)
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 601 $ids.substring(0, $ids.length - 1)
}

# Rule 602 - VMs should not have full SCSI commandset enabled
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  if ($vm.fullscsicommands)
  {
    $ids += $vm.Name + " (" + $vm.guid + ")`n"
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 602 $ids.substring(0, $ids.length - 1)
}

# Rule 603 - Avoid configuring virtual machines with multiple targets on the same SCSI controller if possible
# PLACEHOLDER - TO BE IMPLEMENTED

# Rule 604 - A disk might have performance issues due to VHD physical sector size less than hosting physical disk sector size
$ids = ""
foreach ($vm in $discov.hyperv.vmms.virtual_machines)
{
  foreach ($diskInfo in $vm.disksInfo)
  {
    if ($diskInfo.VhdPhysicalSectorSize -lt $diskInfo.PhysicalDiskSectorSize)
    {
      $ids += $vm.Name + " (" + $vm.guid + ") - " + $diskInfo.path + "`n"
      break
    }
  }
}
if ($ids.length -gt 1)
{
  RuleViolation 604 $ids.substring(0, $ids.length - 1)
}

#
# CRM related rules
# 
 
# Rule 650 - A Hyper-V storage pool file path allocated to a child pool by the
# parent pool is not a subirectory of the parent pool path.
$ids = ""
$id = ""
$resourceSubType = "Microsoft:Hyper-V:Virtual Hard Disk"
$id = (VerifyStoragePathsStrictSubset $resourceSubType)

if ($id.length -gt 1)
{
  $ids += $resourceType + ":`n" + $id + "`n" 
}
 
$id = ""
$resourceSubType = "Microsoft:Hyper-V:Virtual CD/DVD Disk"
$id = (VerifyStoragePathsStrictSubset $resourceSubType)

if ($id.length -gt 1)
{
  $ids += $resourceType + ":`n" + $id + "`n"
}
 
$id = ""
$resourceSubType = "Microsoft:Hyper-V:Virtual Floppy Disk"
$id = (VerifyStoragePathsStrictSubset $resourceSubType)

if ($id.length -gt 1)
{
  $ids += $resourceSubType + ":`n" + $id + "`n"
}

if ($ids.length -gt 1)
{
  RuleViolation 650 $ids.substring(0, $ids.length - 1)
}

# Rule 652 - A Hyper-V storage file path is mapped to
# multiple resource pools.
$ids = ""
$id = ""
$resourceSubType = "Microsoft:Hyper-V:Virtual Hard Disk"
$id = (VerifyStoragePathOnlyInOnePool $resourceSubType)

if ($id.length -gt 1)
{
  $ids += $resourceType + ":`n" + $id + "`n" 
}
 
$id = ""
$resourceSubType = "Microsoft:Hyper-V:Virtual CD/DVD Disk"
$id = (VerifyStoragePathOnlyInOnePool $resourceSubType)

if ($id.length -gt 1)
{
  $ids += $resourceType + ":`n" + $id + "`n"
}
 
$id = ""
$resourceSubType = "Microsoft:Hyper-V:Virtual Floppy Disk"
$id = (VerifyStoragePathOnlyInOnePool $resourceSubType)

if ($id.length -gt 1)
{
  $ids += $resourceSubType + ":`n" + $id + "`n"
}

if ($ids.length -gt 1)
{
  RuleViolation 652 $ids.substring(0, $ids.length - 1)
}

#
# RULES 6XX-XXX: Everything else
#

} #end Violation Detectors

#
# ----
# MAIN
# ----
#
# Custom namespace
$tns="http://schemas.microsoft.com/mbca/models/Hyper-V/2010/12"

# Rule violation document
$xdoc = [xml]"<HyperVComposite xmlns='$tns' />"

# Wrapper for element creation function in custom namespace
# NOTE: These global variables are used in above rule generator functions
$create = ({$xdoc.createElement($args[0],$tns)}).invokeReturnAsIs
$addElem = $xdoc.DocumentElement.appendChild

# Make discoveries
# NOTE: Used by rule violation detectors
PopulateWmiCache
CreateHashCache
$discov = @{}
$discov.parent = (DiscoverParent)
$discov.hyperv = (DiscoverHyperV)
Import-Module FailoverClusters -ErrorAction SilentlyContinue

# Run violation detectors
.($detectors)

# Save xml document (Test Only) 
#$xdoc.save("$HOME\Desktop\hyper-v_violations.xml")

# Return the xml document
$xdoc
