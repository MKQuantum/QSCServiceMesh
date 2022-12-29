# QSCServiceMesh
<img width="368" alt="image" src="https://user-images.githubusercontent.com/121593006/209900698-b90dc96b-2f27-45ff-a5c5-4613bebd797d.png">

This POC is a collaboration between IBM, CIBC, and GitHub to leverage IBM's existing [Quantum Safe Encryption ingress controller work for Kubernetes](https://github.com/IBM/qsc-ingress), and try and apply it to an ISTIO Service Mesh instance.

Service Mesh has the ability to abstract away security and othe cross-cutting concerns from Developers and leverages Kubernetes primitizes such as the Sidecar Pattern which can extend the functionality of a Service running in the Mesh without having to change the Service.

The POC will try and leverage the Sidecar Pattern to apply a Quantum Safe TLS encryption scheme to the Services running in the Mesh, without having to change the Services themselves.  ISTIO Service Mesh has a feature called "Auto mTLS" which allows all inter-mesh to be mTLS encrypted without any configuration.  This coud possibly be extended to Multiple Clusters across Multiple Cloud via the [Submariner Project](https://submariner.io)

A successful POC should demonstrate the ability to leverage [Cryptographic Agility](https://www.techtarget.com/searchenterpriseai/definition/crypto-agility) in an Enterprise Environment that is leveraging Service Mesh that needs to be protected against possible decryption of data by a future Quantum Computer running [Shor's Algorithm](https://quantum-computing.ibm.com/composer/docs/iqx/guide/shors-algorithm) or other future Quantum Software.
