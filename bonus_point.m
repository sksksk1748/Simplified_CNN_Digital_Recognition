I = cell(1,200); %這個好像是創200個房間用來一個放圖片信息
container = zeros(200,9);

% step 10. 加分題
prompt = '1st number (0~9): ';
x = input(prompt);
prompt = '2nd number (0~9): ';
y = input(prompt);

for b=1:200
   % 正常
   %m1=imread(['.\train1000\',int2str(b),'.png']); %m1是一個公共變量會不停的被下一張圖片信息覆蓋最後是最後一張圖片的信息
   %I{b}=m1; %I{1}。。。I{200}就是每一張圖片的信息
   % 加分
   if b <= 100
       m1=imread(['.\train1000\',int2str(x*100+b),'.png']);
   else if b > 100
       m1=imread(['.\train1000\',int2str(y*100+b),'.png']);
   end
   end
   I{b}=m1; %I{1}。。。I{200}就是每一張圖片的信息

% step 1. 28*28 resize to  8*8
img = imresize(I{b},[8, 8]);
img = im2double(img);

filter_first = [-1 -1 1;-1 0 1;-1 1 1];
filter_second = [1 1 -1;1 1 -1;0 1 -1];
%filter_first = [6 -5 12;-9 10 -6;15 -17 16];
%filter_second = [-1 -7 -1;5 1 -1;-1 -3 -1];
% step 2. two filter convolution
conv_first = imfilter(img,filter_first,'conv');
conv_second = imfilter(img,filter_second,'conv');

% step 3. max pooling
fun = @(block_struct) max(block_struct.data(:));
maxpool_first = blockproc (conv_first, [2 2], fun);
maxpool_second = blockproc (conv_second, [2 2], fun);

% step 4. two filter convolution
conv_first_2 = imfilter(maxpool_first,filter_first,'conv');
conv_second_2 = imfilter(maxpool_second,filter_second,'conv');

% step 5. max pooling
maxpool_first_2 = blockproc (conv_first_2, [2 2], fun);
maxpool_second_2 = blockproc (conv_second_2, [2 2], fun);

% step 6. flatten 並加常數項
flatten_first = reshape(maxpool_first_2.',1,[]);
flatten_second = reshape(maxpool_second_2.',1,[]);
flatten = [flatten_first, flatten_second, 1];
container(b,:) = flatten;

end
% step 7. linear regression 獲得係數矩陣
% X 的大小是 200x9
% Y 的大小是 200x1

% 加分
Y = zeros(200,1);
for c = 1:200
    if c >100
        Y(c,:) = y;
    else if c <=100
        Y(c,:) = x;
        end
    end
end

%container = container/255;
A = container\Y;

% step 8. 線性回歸
Yp = container * A;
%plot(Yp)

count_one = 0;
count_two = 0;
count_three = 0;
count_four = 0;

% 加分
for b =1:200
    % Y(b):real ,Yp(b):predict
    % 0 0 
    if Yp(b) < (x+y)/2 & Y(b) == x  
        count_one = count_one + 1; 
    % 1 0
    else if Yp(b) >= (x+y)/2 & Y(b) == x  
        count_two = count_two + 1;
    % 0 1    
    else if Yp(b) < (x+y)/2 & Y(b) == y  
        count_three = count_three + 1;
     % 1 1
    else if Yp(b) >= (x+y)/2 & Y(b) == y  
        count_four = count_four + 1; 
        end
        end
        end
    end
end
disp("           real");
disp(['         [' num2str(x) ']  [' num2str(y) ']']);
disp([' pre  [' num2str(x) '] ' num2str(count_one) ' ' num2str(count_three)]);
disp(['dict  [' num2str(y) '] ' num2str(count_two) ' ' num2str(count_four)]);

% step 9. 隨機測試
% 0~200 uint8 vector

%加分
count = 1;
while(1)
    if count == 16
        break;
    end
    r = randi([x*100 (y+1)*100],1,1);
    if r > y*100 & r < (y+1)*100+1
        randtemp(:,count) = r;
        count = count +1;
    end
    if r > x*100 & r < (x+1)*100+1
        randtemp(:,count) = r;
        count = count +1;
    end
    
end    
for num = 1:15
    % 這個順序很重要，因為會影響title 顯示順序
    subplot(3,5,num)
    img=imread(['.\train1000\',int2str(randtemp(:,num)),'.png']);
    imshow(img) 
    % 這個順序很重要，因為會影響title 顯示順序
    if randtemp(:,num) > x*100 & randtemp(:,num) < (x+1)*100+1
       randtemp(:,num) = randtemp(:,num) - (x)*100;
    end
    if randtemp(:,num) > y*100 & randtemp(:,num) < (y+1)*100+1
       randtemp(:,num) = randtemp(:,num) - (y-1)*100;
    end
    randtemp(:,num);
    Y(randtemp(:,num));
    Yp(randtemp(:,num));    
    %titleStr=[num2str(Y(r(:,num))),' (',num2str(r(:,num)),')']; 
    
    % 0 0 
    if Yp(randtemp(:,num)) < (x+y)/2 & Y(randtemp(:,num)) == x
        titleStr=[num2str(Y(randtemp(:,num))),' (',num2str(randtemp(:,num)),')'];    
        title(titleStr);
    % 1 0
    else if Yp(randtemp(:,num)) >= (x+y)/2 & Y(randtemp(:,num)) == x
        titleStr=[num2str(y),' (',num2str(randtemp(:,num)),')'];
        title(titleStr,'Color', 'r') 
    % 0 1    
    else if Yp(randtemp(:,num)) < (x+y)/2 & Y(randtemp(:,num)) == y 
        titleStr=[num2str(x),' (',num2str(randtemp(:,num)),')'];
        title(titleStr,'Color', 'r')
     % 1 1
    else if Yp(randtemp(:,num)) >= (x+y)/2 & Y(randtemp(:,num)) == y
        titleStr=[num2str(Y(randtemp(:,num))),' (',num2str(randtemp(:,num)),')'];
        title(titleStr);
        end
        end
        end
    end
end