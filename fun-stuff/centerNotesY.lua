---@diagnostic disable: undefined-global, lowercase-global
function start()
    middle = getScreenHeight()/2

    for i=0,7 do
		setActorY(middle - getActorHeight(i)/2, i)
	end
end

function update(elapsed)
	for i=0,7 do
		setActorY(middle - getActorHeight(i)/2, i)
	end
end