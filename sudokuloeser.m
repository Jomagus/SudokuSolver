function S = sudokuloeser(S)
% SUDOKULOESER  Solves a given NxN Sudoku supplied as a Matrix, where missing fields are "0".

    % First we check if we dont need guesses to solve the Sudoku   

    S = unique(S);
        
    if issolved(S)
        return
    end
    
    % Now we solve the Sudoku with Backtracking. If there are multiple possible numbers,
    % we choose one and see, if we can solve the Sudoku, if it fails we backtrack and 
    % look at the other possible numbers.
    
    [S, success] = accepter(S,1,1);
    
    % If the success flag is set, our Sudoku is solved, otherwise there is no possible solution.

    if success == 1
        return;
    else
        S=[];
    end
end



function [flag] = sudokutester(K,i,j,z)
% SUDOKUTESTER  Checks if a number is allowed in a given place.
%   a = sudokutester(K,i,j,z) checks if z is allowed to be placed on position (i,j) in the Sudoku K, if so, returns 1, otherwise 0.

if (K(i,j) == 0) && (isempty(find(K(i,:) == z, 1))) && (isempty(find(K(:,j) == z, 1)))
    
    % Our Sudukos have the Rule, that every number in a subsquare must be unique, meaning for a 3x3 Sudoku:
    %
    % A A A | B B B | C C C
    % A A A | B B B | C C C
    % A A A | B B B | C C C
    %----------------------
    % D D D | E E E | F F F
    % D D D | E E E | F F F
    % D D D | E E E | F F F
    %----------------------
    % G G G | H H H | I I I
    % G G G | H H H | I I I
    % G G G | H H H | I I I
    %
    % that for each subsquare A-I there cant be a number twice in it


    SubSize=sqrt(size(K));
    Subi=fix((i-1)/SubSize(1));
    Subj=fix((j-1)/SubSize(2));
    Subi = Subi * SubSize(1);
    Subj = Subj * SubSize(2);

    for SubI=1:SubSize(1)
        for SubJ=1:SubSize(2)
            
            if K(Subi+SubI,Subj+SubJ) == z
                flag = 0;
                return
            end
        end
    end  
flag =  1;           
else
flag = 0;
end
end

function PosSol = Solutions(K,istart,jstart)
% POSSOL Returns a 3 dimensional Matrix that contains all possible numbers for a given sudoku.
% In the return Matrix the value on position (i,j,k) is 1 only if its allowed to place the number
% k on position (i,j) of the sudoku (that is supplied to this function).

PosSolT = zeros(size((K),1),size((K),1),size((K),1));

for d3n = 1:size((K),1) % runs over all possible numbers
    for d1n = istart:size((K),1)
        for d2n = jstart:size((K),1)
            PosSolT(d1n,d2n,d3n)= sudokutester(K,d1n,d2n,d3n);
        end 
    end
end
PosSol = PosSolT;
end

function K = unique(K)
% UNIQUE Fills all numbers in the sudoku that are possible without backtracking (meaning that there is alway only 1 choice to make)

    while 1
        KCopy = uniquehelper(K);
        if isequal(K,KCopy)
            break
        end
        K = KCopy;
    end

    function K = uniquehelper(K)
        PosSol = Solutions(K,1,1);

        for di = 1:size((K),1)
            for dj = 1:size((K),1)
                if length(find(PosSol(di,dj,:)==1))==1
                    K(di,dj)=find(PosSol(di,dj,:)==1);
                end
            end 
        end
    end
end

function flag = issolved(K)
% ISSOLVED Checks if supplied sudoku is solved.

    if isempty(find(K==0,1))
        HMat = zeros(size(K,1));
        for di = 1:size(K,1)
            for dj = 1:size(K,1)
                HMat(di,dj)=sudokutesterhelper(K,di,dj,K(di,dj));
            end
        end
        
        if all(all(HMat))
            flag = 1;
            return;
        else
            flag = 0;
        end
    else
        flag = 0;
    end
    
    
    function [flag] = sudokutesterhelper(K,ci,cj,z)
        K(ci,cj)=0;
        if (isempty(find(K(ci,:) == z, 1))) && (isempty(find(K(:,cj) == z, 1)))
            
            SubSize=sqrt(size(K));
            Subi=fix((ci-1)/SubSize(1));
            Subj=fix((cj-1)/SubSize(2));
            Subi = Subi * SubSize(1);
            Subj = Subj * SubSize(2);

            for SubI=1:SubSize(1)
                for SubJ=1:SubSize(2)

                    if K(Subi+SubI,Subj+SubJ) == z
                        flag = 0;
                        return
                    end
                end
            end  
        flag =  1;           
        else
        flag = 0;
        end
    end
end

function [ZwL, success] = accepter(K,curi,curj)
% ACCEPTER Trys so solve the sudoku with backtracking.

    akti=curi;
    aktj=curj;
    
    while 1
        
        if K(akti,aktj) ~= 0    %fuehrt akt zur ersten unsicheren Stelle
            akti = akti+1;
            if akti > size(K,1)
                akti = 1;
                aktj = aktj +1;
            end
            if aktj > size(K,1)  %falls ganz am Ende
               ZwL = K;
               if issolved(K)
                    success = 1;
               else
                   success = 0;
               end
               return
            end
            
            continue
        end
        break
    end
    
    PosSol = Solutions(K,akti,aktj);    
    possible = find(PosSol(akti,aktj,:) == 1);   % gives all possibilities
      
    KCopy = K;              % to save K before testing
    
    for assumed = 1:length(possible)
        K = KCopy;          %resettet K before each unsuccessful attempt
        K(akti,aktj)=possible(assumed);
        K = unique(K);
        if issolved(K)
            ZwL = K;
            success = 1;
            return
        end
        
        [KNew, success] = accepter(K,akti,aktj);
        if success == 1
            ZwL = KNew;
            return
        end
    end
    
    ZwL=KCopy;
    success=0;
end
