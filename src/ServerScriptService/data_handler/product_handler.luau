local sss = game:GetService("ServerScriptService")
local plrs = game:GetService("Players")
local mps = game:GetService("MarketplaceService")

local sensitive_list = require(sss.sensitive_list)
local network = require(sss:WaitForChild("network_server"))

local data_handler = require(sss.data_handler)
local product_functions = require(sss.data_handler.product_functions)

local function product_purchase_requested(player, product_id)
    if product_functions[product_id] == nil then
        warn(("[ProductHandler] Product purchase requested for player %s (ID: %d) with product ID %s, but no function found"):format(player.Name, player.UserId, product_id))
        return
    end

    -- Prompt a purchase
    mps:PromptProductPurchase(player, product_id)
end

local function check_purhcase_id_async(player, purchase_id, grand_product_function)
    local profile = data_handler.profiles[player.UserId]
    if profile:IsActive() then
        
        -- Get cache of previous purchase_ids
        local purchase_id_cache = profile.Data.purchase_id_cache

        -- Grant product if not previous logged
        if table.find(purchase_id_cache, purchase_id) == nil then

            -- Grant product
            local success, err = pcall(grand_product_function)

            if not success then
                warn(("[ProductHandler] Error granting product to player %s (ID: %d): %s"):format(player.Name, player.UserId, err))
                return Enum.ProductPurchaseDecision.NotProcessedYet
            end

            -- Remove oldest purchase_id from cache if cache is full
            while #purchase_id_cache >= sensitive_list.max_purchase_id_cache_size do
                table.remove(purchase_id_cache, 1)
            end

            -- Add new purchase_id to cache
            table.insert(purchase_id_cache, purchase_id)
        end

        -- Verify that the product has been saved to the profile
        local function is_purchase_saved()
            local saved_cache = profile.LastSavedData.purchase_id_cache
            if saved_cache ~= nil then
                return table.find(saved_cache, purchase_id) ~= nil
            else
                return false
            end
        end

        if is_purchase_saved() then
            return Enum.ProductPurchaseDecision.PurchaseGranted
        end

        -- Periodically check if the purchase_id has been saved UNTIL it is, OR the profile's session ends
        while profile:IsActive() do

			local last_saved_data_copy = profile.LastSavedData

			profile:Save()

			if profile.LastSavedData == last_saved_data_copy then
				profile.OnAfterSave:Wait()
			end

			if is_purchase_saved() then
				return Enum.ProductPurchaseDecision.PurchaseGranted
			end

			if profile:IsActive() then
				task.wait(10)
			end
        end
    end

    return Enum.ProductPurchaseDecision.NotProcessedYet
end

local function process_receipt(receipt_info)
    local player = plrs:GetPlayerByUserId(receipt_info.PlayerId)

    if player then
        local profile = data_handler.profiles[player.UserId]

        if profile then

            -- Additional check to ensure the product function exists
            if product_functions[receipt_info.ProductId] == nil then
                warn(("[ProductHandler] Product purchase requested for player %s (ID: %d) with product ID %s, but no function found"):format(player.Name, player.UserId, receipt_info.ProductId))
                return Enum.ProductPurchaseDecision.NotProcessedYet
            end

            -- Grand product and return decision
            local product_purchase_decision = check_purhcase_id_async(
                player,
                receipt_info.PurchaseId,
                function()
                    product_functions[receipt_info.ProductId](receipt_info, player, profile)
                end)
            
            return product_purchase_decision

        else
            warn(("[ProductHandler] Profile not found for player %s (ID: %d)"):format(player.Name, player.UserId))
            return Enum.ProductPurchaseDecision.NotProcessedYet
        end

    end

    return Enum.ProductPurchaseDecision.NotProcessedYet
end

-- Connects process_receipt callback to MarketplaceService
mps.ProcessReceipt = process_receipt

network.product_purchase.On(product_purchase_requested)

return {}