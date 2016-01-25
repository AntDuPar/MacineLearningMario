startState = savestate.create(1);
savestate.save(startState);
function moveLeft()
	joyr = resetInput();
	joyr['left'] = true;
	return joyr;
end;

function moveRight()
	joyr = resetInput();
	joyr['right'] = true;
	return joyr;
end;

function jump()
	joyr = resetInput();
	joyr['A'] = true;
	return joyr;
end;

function jumpLeft()
	joyr = resetInput();
	joyr['A'] = true;
	joyr['left'] = true;
	return joyr;
end;

function jumpRight()
	joyr = resetInput();
	joyr['A'] = true;
	joyr['right'] = true;
	return joyr;
end;
a1 = {}
function randomInput()
	x = math.random(5);
	if (x == 1) then
		return moveRight();
	end;
	if (x == 2) then
		return jump();
	end;
	if (x == 3) then
		return moveLeft();
	end;
	if (x == 4) then
		return jumpLeft();
	end;
	if (x == 5) then
		return jumpRight();
	end;
end;

function resetInput()
	joyr = joypad.read(1);
	joyr['left'] = false;
	joyr['right'] = false;
	joyr['A'] = false;
	return joyr
end;
	
function fitnessL()
	marioxpos = memory.readbyte(0x6D) * 0x100 + memory.readbyte(0x86);
	return marioxpos;
end;

function loadSS()
	savestate.load(startState);
	currDis = 0;
	maxDis = 0;
	timer = 0;
end;

function breed()
	maxFit = 0;
	leng = table.getn(a1);
	for m = 1, (leng-1) do
		if(a1[m]["fitness"] > maxFit) then
			maxFit = a1[m]["fitness"];
		end;
	end
	print (maxFit);
	fitnessSum = 0;
	for i = 1, (leng-1) do
		fitnessSum = fitnessSum + a1[i]["fitness"];
	end
	g = 0;
	h = 0;
	for x = 1, ((leng-1)/2) do
		fitnessSumtmp = fitnessSum;
		crossOver = math.random(10);
		if (crossOver <= 7) then
			wheel = math.random(fitnessSum);
			for q = 1, (leng-1) do
				if(wheel > (fitnessSumtmp - a1[q]["fitness"])) then
					g = q
					break;
				else
					fitnessSumtmp = fitnessSumtmp - a1[q]["fitness"];
				end;
			end
			wheel = math.random(fitnessSum);
			for j = 1, (leng-1) do
				if(wheel > (fitnessSumtmp - a1[j]["fitness"])) then
					h = j
					break;
				else
					fitnessSumtmp = fitnessSumtmp - a1[j]["fitness"];
				end;
			end
			leng1 = table.getn(a1[g]);
			leng2 = table.getn(a1[h]);
			crossOverSpot = 0;
			length = 0;
			if (leng1 > leng2) then
				crossOverSpot = math.random(leng2);
				length = leng1;
			else
				crossOverSpot = math.random(leng1);
				length = leng2;
			end;
			for l = 0, length do
				if(l < crossOverSpot) then
					a1[x][l] = a1[g][l];
					a1[leng-1][l] = a1[h][l];
				else
					a1[x][l] = a1[h][l]
					a1[leng-1][l] = a1[g][l];
				end;
			end
		end;
	end
	for t = 1, (leng-1) do --random mutation very low chance
		curLeng = table.getn(a1[t]);
		for y = 1, (curLeng-1) do
			mutate = math.random(10000);
			if (mutate <= 7) then
				a1[t][y] = randomInput();
			end;
		end
	end
end;

function findNextMove(x, y)
	if(a1[x] and a1[x][y] ~= nil) then
		return a1[x][y]
	else
		if(a1[x] == nil) then
			a1[x] = {}
		end;
		a1[x][y] = randomInput();
		return a1[x][y]
	end;
end;

currDis = 1;
maxDis = 0;
timer = 0;
i = 1;
j = 1;
n = 0;
move = randomInput();
while (true) do
	move = findNextMove(i, j);
	joypad.set(1, move);
	currDis = fitnessL();
	if(currDis > maxDis) then
		maxDis = currDis;
		timer = 0;
	else
		timer = timer + 1;
	end;
	if(timer >= 120) then
		if(a1[i][j+1] ~= nil) then
			endl = table.getn(a1[i]);
			for o = (j+1), (endl-1) do
				a1[i][o] = nil;
			end
		end;
		j = 1;
		if(i >= 21) then
			i = 1;
			--print "Breed Time"
			breed();
		else
			a1[i]["fitness"] = maxDis;
			i = i + 1;
		end;
		loadSS();
	end;
	j = j + 1;
	FCEU.frameadvance();
end;