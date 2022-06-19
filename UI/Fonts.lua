----------------------------------------------------------
-- Name: Fonts											--
-- Description: Contains everything about custom fonts	--
----------------------------------------------------------

MTSLUI_Fonts = {
	-- Type of font used
	name = "Fonts\\FRIZQT__.TTF",
	-- Fontsize of text
	size = {
		large = 12, --13,
		normal = 10, --11,
		small = 8, --10,
	},
	-- Colors available
	colors = {
		-- Colors used for text
		text = {
			success = "|cff1eff00",
			normal	= "|cffffffff",
			title	= "|cffffff00",
			error	= "|cffff0000",
		},
		-- Colors use to display money
		money = {
			gold	= "|cffffd700",
			silver	= "|cffc7c7cf",
			copper	= "|cffeda55f"
		},
		-- Colors used for a font based on quality of an item
		quality = {
			poor		= "|cff9d9d9d",
			common		= "|cffffffff",
			uncommon	= "|cff1eff00",
			rare		= "|cff0070dd",
			epic		= "|cffa335ee",
			legendary	= "|cffff8000"
		},
		-- Colors used for a font based if an item is "available"/"learnable"
		available = {
			yes	= "|cff1eff00",
			no	= "|cffff0000",
		}
	},

	-------------------------------------------------------------------------
	-- Returns the color for text based on the quality
	--
	-- @item_quality	String	The quality of the item
	--
	-- returns			String	The color for the text for the given quality
	--------------------------------------------------------------------------
	GetTextColorOnQuality = function (self, item_quality)
		if self.colors.quality.item_quality ~= nil then
			return self.colors.quality.item_quality
		end
		return self.colors.text.normal
	end,
}
