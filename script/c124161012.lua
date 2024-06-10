--SunLightshape's Shrine
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(_,c) return c:IsSetCard(0xf20) end)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--effect 2
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.cst2)
	e3:SetTarget(s.tg2)
	e3:SetOperation(s.op2)
	c:RegisterEffect(e3)
	--effect 3
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_TRIGGER)
	e4:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(0,LOCATION_SZONE)
	e4:SetCondition(s.con3)
	e4:SetTarget(s.tg3)
	c:RegisterEffect(e4)
end

--effect 1
function s.val1filter(c)
	return c:IsPublic()  
end

function s.val1(e,c)
	return Duel.GetMatchingGroupCount(s.val1filter,e:GetHandlerPlayer(),LOCATION_HAND,0,nil)*300
end

--effect 2

function s.cst2ffilter(c,ctype)
	local key=TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP 
	return c:IsSetCard(0xf20) and c:IsType(ctype&key) and c:IsAbleToHand() and not c:IsType(TYPE_FIELD)
end

function s.cst2filter(c,tp)
	return not c:IsPublic() and Duel.IsExistingMatchingCard(s.cst2ffilter,tp,LOCATION_DECK,0,1,nil,c:GetType())
end

function s.cst2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cst2filter,tp,LOCATION_HAND,0,nil,tp)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_CONFIRM):GetFirst()
	Duel.ConfirmCards(1-tp,sg)
	Duel.ShuffleHand(tp)
	local key=TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP 
	e:SetLabel(sg:GetType()&key)
end


function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local ctype=e:GetLabel()
	local hg=Duel.GetMatchingGroup(s.cst2ffilter,tp,LOCATION_DECK,0,nil,ctype)
	if #hg>0 then
		local shg=aux.SelectUnselectGroup(hg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND)
		if Duel.SendtoHand(shg,nil,REASON_EFFECT) then
			Duel.ConfirmCards(1-tp,shg)
			Duel.ShuffleDeck(tp)
			Duel.BreakEffect()
			Duel.DisableShuffleCheck()
			local dg=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_HAND,0,nil)
			local sdg=aux.SelectUnselectGroup(dg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TODECK)
			Duel.SendtoDeck(sdg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end

--effect 3
function s.con3filter(c)
	return c:IsPublic() and c:IsSetCard(0xf20)
end

function s.con3(e)
	local tp=e:GetHandler():GetControler()
	return Duel.GetMatchingGroupCount(s.con3filter,tp,LOCATION_HAND,0,nil)>0
end

function s.tg3(e,c)
	return c:IsFacedown()
end
