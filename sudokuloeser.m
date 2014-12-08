function S = sudokuloeser(S)

    %Hier schauen wir uns eindeutige Loesungen an    

    S = eindeutig(S);
        
    if issolved(S)
        return
    end
    
    %Hier beginnt der eigentliche Loeser
    
    [S, succes] = annehmer(S,1,1);
    
    if succes == 1
        return;
    else
        S=[];
    end
end



function [flag] = sudokutester(K,i,j,z)
if (K(i,j) == 0) && (isempty(find(K(i,:) == z, 1))) && (isempty(find(K(:,j) == z, 1)))
    
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
PosSolT = zeros(size((K),1),size((K),1),size((K),1));

for d3n = 1:size((K),1) %läuft durch alle möglichen Zahlen
    for d1n = istart:size((K),1)
        for d2n = jstart:size((K),1)
            PosSolT(d1n,d2n,d3n)= sudokutester(K,d1n,d2n,d3n);
        end 
    end
end
PosSol = PosSolT;
end

function K = eindeutig(K)
    while 1
        KCopy = eindeutighelper(K);
        if isequal(K,KCopy)
            break
        end
        K = KCopy;
    end

    function K = eindeutighelper(K)
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

function [ZwL, succes] = annehmer(K,curi,curj)
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
                    succes = 1;
               else
                   succes = 0;
               end
               return
            end
            
            continue
        end
        break
    end
    
    PosSol = Solutions(K,akti,aktj);    
    moeglich = find(PosSol(akti,aktj,:) == 1);   %gibt alle Moeglichkeiten an
      
    KCopy = K;              %sichert vor dem Testen
    
    for assumed = 1:length(moeglich)
        K = KCopy;          %resettet K vor jedem durchlauf ohen erfolg
        K(akti,aktj)=moeglich(assumed);
        K = eindeutig(K);
        if issolved(K)
            ZwL = K;
            succes = 1;
            return
        end
        
        [KNew, succes] = annehmer(K,akti,aktj);
        if succes == 1
            ZwL = KNew;
            return
        end
    end
    
    ZwL=KCopy;
    succes=0;
end







