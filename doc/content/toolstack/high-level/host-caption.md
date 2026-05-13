Hand-drawn architecture diagram of the XAPI toolstack in the XCP-ng / Xen environment.

The diagram is organized in horizontal layers and vertical domains.

At the bottom is the physical hardware layer labeled “Hardware: PC (or ARM)”. Above it is the hypervisor layer labeled “Xen 4.4+”.

Above the hypervisor is Domain 0, the privileged control domain. Inside Domain 0, the following components are shown:

* “Stunnel” at the top left, connected downward to “xapi”.
* “xapi” is the central management component. It communicates with:

  * “xcp-rrdd” through a connection labeled “json rpc”.
  * “xenopsd” through another connection labeled “json rpc”.
  * “SM” (storage manager), shown attached to the right side of xapi.
  * “xcp-networkd”, connected below xapi.
* “xenopsd” is shown above two library blocks labeled “libxc” and “libxl”, indicating that xenopsd uses these Xen control libraries.

To the right of Domain 0 are several vertical columns representing guest virtual machines, each labeled “Guest” at the bottom. The diagram suggests multiple guests by drawing several parallel guest columns and an ellipsis (“.....”) between some of them.

Along the left edge of the guest area are backend services running in Domain 0:

* “blkback”
* “tapdisk”
* “netback”
* “xenconsoled”
* “xenstored”

Each backend service is connected horizontally to one or more guest domains:

* “blkback” connects to a guest through an operation labeled “grant map/unmap”.
* “tapdisk” connects through “grant copy”.
* “netback” connects directly to another guest.
* Additional horizontal connections continue toward further guest domains on the right.

The diagram illustrates the relationship between the Xen hypervisor, Domain 0 management services, Xen backend drivers, and multiple guest virtual machines, including the communication paths used for storage, networking, and guest management.


