; Created	20120223	from http://people.revoledu.com/kardi/tutorial/kMean/matlab_kMeans.htm


;%%%%%%%%%%%%%%%%
;%                                                        
;% kMeansCluster - Simple k means clustering algorithm                                                              
;% Author: Kardi Teknomo, Ph.D.                                                                  
;%                                                                                                                    
;% Purpose: classify the objects in data matrix based on the attributes    
;% Criteria: minimize Euclidean distance between centroids and object points                    
;% For more explanation of the algorithm, see http://people.revoledu.com/kardi/tutorial/kMean/index.html    
;% Output: matrix data plus an additional column represent the group of each object               
;%                                                                                                                
;% Example: m = [ 1 1; 2 1; 4 3; 5 4]  or in a nice form                         
;%          m = [ 1 1;                                                                                     
;%                2 1;                                                                                         
;%                4 3;                                                                                         
;%                5 4]                                                                                         
;%          k = 2                                                                                             
;% kMeansCluster(m,k) produces m = [ 1 1 1;                                        
;%                                   2 1 1;                                                                 
;%                                   4 3 2;                                                                  
;%                                   5 4 2]                                                                  
;% Input:
;%   m      - required, matrix data: objects in rows and attributes in columns                                                 
;%   k      - optional, number of groups (default = 1)
;%   isRand - optional, if using random initialization isRand=1, otherwise input any number (default)
;%            it will assign the first k data as initial centroids
;%
;% Local Variables
;%   f      - row number of data that belong to group i
;%   c      - centroid coordinate size (1:k, 1:maxCol)
;%   g      - current iteration group matrix size (1:maxRow)
;%   i      - scalar iterator 
;%   maxCol - scalar number of rows in the data matrix m = number of attributes
;%   maxRow - scalar number of columns in the data matrix m = number of objects
;%   temp   - previous iteration group matrix size (1:maxRow)
;%   z      - minimum value (not needed)
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


pro kmeanscluster









end
