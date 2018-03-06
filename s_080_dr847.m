%% Maze Generator and Solving Algorithm 

clear; clc;

global maze dirMapV dirMapO dirMapDX dirMapDY blockMaze weightMaze n solutionMaze


n = 36; % THE SIZE OF THE SQUARE MAZE


maze = zeros(n);
blockMaze = ones(2*n+1);
weightMaze = zeros(2*n+1);
solutionMaze = zeros(2*n+1);

dirBitKeys = {'N','S','E','W'};
dirMapV = containers.Map(dirBitKeys,[1 2 4 8]);
dirMapO = containers.Map(dirBitKeys,{'S','N','W','E'});
dirMapDX = containers.Map(dirBitKeys,[0,0,1,-1]);
dirMapDY = containers.Map(dirBitKeys,[-1,1,0,0]);

%% Runs the necessary functions to demonstrate the project

generateMaze(1,1);
%displayMaze();
translateMaze();
plotMaze(1);
mazeSolver(2,1,1);
backTrack(n*2,n*2+1);
plotMaze(2);

%% Generates a maze of size n using the Hunt and Kill Method 
%(http://weblog.jamisbuck.org/2011/1/24/maze-generation-hunt-and-kill-algorithm)
function generateMaze(cx, cy)
    global maze dirMapV dirMapO dirMapDX dirMapDY
    persistent foundReset
    dir = ['N','S','E','W'];
    validDir = "";
    for i = 1:4
        nx = cx + dirMapDX(dir(i)); 
        ny = cy + dirMapDY(dir(i));
        if(nx > 0) && (nx <= length(maze)) &&... 
          (ny > 0) && (ny <= length(maze)) &&... 
          (maze(ny, nx) == 0)
          validDir = validDir + dir(i);
        end
    end
    if strlength(validDir) > 0
        validDir = char(validDir);
        x=randi(length(validDir),1);
        nx = cx + dirMapDX(validDir(x)); 
        ny = cy + dirMapDY(validDir(x));
        maze(cy, cx) = maze(cy, cx) + dirMapV(validDir(x));
        maze(ny, nx) = maze(ny, nx) + dirMapV(dirMapO(validDir(x)));
        generateMaze(nx, ny);
    else
        foundReset = false;
        for r = 1:length(maze)
            for c = 1:length(maze)
                if maze(r, c) == 0 && ~foundReset
                    for j = 1:4
                        rx = c + dirMapDX(dir(j)); 
                        ry = r + dirMapDY(dir(j));
                        if(rx > 0) && (rx <= length(maze)) &&... 
                          (ry > 0) && (ry <= length(maze)) &&... 
                          ~(maze(ry, rx) == 0)
                            validDir = validDir + dir(j);
                        end
                    end
                    if strlength(validDir) > 0
                        foundReset = true;
                        validDir = char(validDir);
                        x=randi(length(validDir),1);
                        rx = c + dirMapDX(validDir(x)); 
                        ry = r + dirMapDY(validDir(x));
                        generateMaze(rx, ry);
                    end
                end
            end
        end
        foundReset = true;
    end
end

%% Prints out the generated maze using the bitwise maze directly (debugging purposed)
function displayMaze()
    global maze n
    for i = 1:n
        for j = 1:n
            if(bitand(fi(maze(i,j),1,8,0),fi(1,1,8,0)) == 0)
                fprintf('+---')
            else
                fprintf('+   ')
            end
        end
        fprintf('+\n')
        for j = 1:n
            if(bitand(fi(maze(i,j),1,8,0),fi(8,1,8,0)) == 0)
                fprintf('|   ')
            else
                fprintf('    ')
            end
        end
        fprintf('|\n')
    end
    for i = 1:n
        fprintf('+---')
    end
    fprintf('+\n')
end

%% Changes the generated bitwise maze into a more friendly boolean maze for solving
function translateMaze()
    global maze blockMaze n
    for i = 1:n
        for j = 1:n
            blockMaze(2*i-1,2*j-1) = 0;
            if(bitand(fi(maze(i,j),1,8,0),fi(1,1,8,0)) == 0)
                blockMaze(2*i-1,2*j) = 0;
            end
        end
        for j = 1:n
            if(bitand(fi(maze(i,j),1,8,0),fi(8,1,8,0)) == 0)
                blockMaze(2*i,2*j-1) = 0;
            end
        end
    end
    blockMaze(:,n*2+1) = 0;
    blockMaze(n*2+1,:) = 0;
    blockMaze(1,2)=1;
    blockMaze(end,n*2)=1;
end

%% Plots the maze in a visually friendly manner, x being what figure to plot in
function plotMaze(x)
    global blockMaze n weightMaze solutionMaze
    unsolvedMaze = figure(x);
    set(unsolvedMaze,'Color','w','Name','Maze','Resize','Off','MenuBar','None');
    for r = 1:2*n+1
        for c = 1:2*n+1
            if blockMaze(r,c) == 0 && weightMaze(r,c) == 0 && solutionMaze(r,c) == 0
                fillColor = 'k';
            elseif solutionMaze(r,c) == 1
                fillColor = 'g';
            elseif weightMaze(r,c) > 0
                fillColor = [(weightMaze(r,c)*2.5)/(4*n*n) 0.4 0.6];
            else
                fillColor = 'w';
            end
            rectangle('Position',[(c-1)*10,(2*n-r+1)*10,10,10],'FaceColor',fillColor,'EdgeColor','k');
        end
    end     
end

%% Solves the given maze in conjunction with backTrack() using a depth first search
function mazeSolver(cx, cy, w)
    global blockMaze weightMaze n dirMapDX dirMapDY
    dir = ['N','S','E','W'];
    weightMaze(cy, cx) = w;
    for i = 1:4
        nx = cx + dirMapDX(dir(i));
        ny = cy + dirMapDY(dir(i));
        if nx == n*2 && ny == n*2+1
            weightMaze(ny,nx)=w+1;
            return;
        elseif(nx > 0) && (nx <= length(blockMaze)) &&... 
          (ny > 0) && (ny <= length(blockMaze)) &&... 
          (blockMaze(ny, nx) == 1) && weightMaze(ny,nx) == 0
            mazeSolver(nx,ny,w+1);
        end
    end
end

%% Generates/stores the best solution for the given maze, to be plotted with plotMaze()
function backTrack(cx,cy)
    global weightMaze solutionMaze dirMapDX dirMapDY
    dir = ['N','S','E','W'];
    for i = 1:4
        nx = cx + dirMapDX(dir(i));
        ny = cy + dirMapDY(dir(i));
        if(nx > 0) && (nx <= length(weightMaze)) &&... 
          (ny > 0) && (ny <= length(weightMaze)) &&... 
          weightMaze(ny,nx) < weightMaze(cy,cx)
            solutionMaze(cy,cx) = 1;
            backTrack(nx,ny);
        end
    end
end