function [vertices, faces] = readobjFaster(filename)

% original by BoffinBlogger 
% https://boffinblogger.blogspot.com/2015/05/faster-obj-file-reading-in-matlab.html
% accessed 10.08.18

% read entire file at once
fid = fopen(filename);
if fid<0
    error(['Cannot open ' filename '.']);
end
[str, count] = fread(fid, [1,inf], 'uint8=>char'); 
fprintf('Read %d characters from %s\n', count, filename);
fclose(fid);

% list of indices that match the regular expression for vertices
vertex_lines = regexp(str,'v [^\n]*\n', 'match'); 

% populate array of vertices
vertices = zeros(length(vertex_lines), 3);
for i = 1: length(vertex_lines)
    v = sscanf(vertex_lines{i}, 'v %f %f %f');
    vertices(i, :) = v';
end

% list of indices that match the regular expression for faces
face_lines = regexp(str,'f [^\n]*\n', 'match');

% populate array of faces
faces = zeros(length(face_lines), 3);
for i = 1: length(face_lines)
    f = sscanf(face_lines{i}, 'f %d//%d %d//%d %d//%d'); % usual expression
    if (length(f) == 6) % vertex indices appears twice (3x2) save every alternate
        faces(i, 1) = f(1); 
        faces(i, 2) = f(3);
        faces(i, 3) = f(5);
        continue
    end
    f = sscanf(face_lines{i}, 'f %d %d %d');             % alternative expression 1
    if (length(f) == 3) % vertex indices
        faces(i, :) = f';
        continue
    end
    f = sscanf(face_lines{i}, 'f %d/%d %d/%d %d/%d');    % alternative expression 2
    if (length(f) == 6) % same as usual case
        faces(i, 1) = f(1);
        faces(i, 2) = f(3);
        faces(i, 3) = f(5);
        continue
    end
    f = sscanf(face_lines{i}, 'f %d/%d/%d %d/%d/%d %d/%d/%d'); % alternative expression 3
    if (length(f) == 9) % vertex indices appear 3x, save every third
        faces(i, 1) = f(1);
        faces(i, 2) = f(4);
        faces(i, 3) = f(7);
        continue
    end
    
    
end


return