function geometricDescriptors = ExtractGeometricDescriptors(mesh,mu)

% based on the paper:
% Pozo, J. M., Villa-Uriol, M. C., & Frangi, A. F. (2011). 
% "Efficient 3D Geometric and Zernike moments computation from unstructured surface meshes". 
% IEEE Transactions on Pattern Analysis and Machine Intelligence, 33(3), 471-484.

    mu=mu/sqrt(mu*mu'); %To ensure that mu is normalized.
    A=[0,0,1]'*mu-mu'*[0,0,1];
    xi=[0,0,1]*mu';
    R=eye(3)+A+1/(1+xi)*A*A; %Rotation matrix from mu to e3 (z axis).
    center=mesh.vertices(1,:); %Approximate center for numerical stability.
    mesh.vertices=(mesh.vertices-center)*R';
    geometricDescriptors=ComputeGeometricDescriptors(mesh);
end