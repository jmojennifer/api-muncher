require 'httparty'

class EdamamApiWrapper
  BASE_URL = "https://api.edamam.com/"
  ID = ENV["EDAMAM_RECIPE_SEARCH_ID"]
  KEY = ENV["EDAMAM_RECIPE_SEARCH_AUTH_KEY"]

  def self.recipe_search(search_term = "", page = 1)

    url = BASE_URL + "search?q=" + search_term.to_s  + "&app_id=" + ID + "&app_key=" + KEY + "&from=" + ((page.to_i - 1) * 10).to_s

    data = HTTParty.get(url)
    total_recipe_num = data["count"]
    more_items_after = data["more"]
    recipe_list = []

    if !data["hits"].nil?
      data["hits"].each do |hit|
        dietary_info = []
        descriptive_labels = []

        name = hit["recipe"]["label"]
        id = hit["recipe"]["uri"][51..82]
        descriptive_labels.push(hit["recipe"]["dietLabels"])
        descriptive_labels.push(hit["recipe"]["healthLabels"])

        hit["recipe"]["digest"].each do |nutrient|
          if nutrient["sub"].nil?
            dietary_info.push(nutrient["label"] + ": " + nutrient["total"].round(2).to_s + nutrient["unit"])
          else
            dietary_info.push(nutrient["label"] + ": " + nutrient["total"].round(2).to_s + nutrient["unit"])
            nutrient["sub"].each do |sub_nutrient|
              dietary_info.push(sub_nutrient["label"] + ": " + sub_nutrient["total"].round(2).to_s + sub_nutrient["unit"])
            end
          end
        end
        api_hash = {more_items_after: more_items_after, total_recipe_num: total_recipe_num, name: name, id: id, recipe_image: hit["recipe"]["image"], source_url: hit["recipe"]["url"], ingredients: hit["recipe"]["ingredientLines"], calories: hit["recipe"]["calories"].to_i, dietary_info: dietary_info, descriptive_labels: descriptive_labels, yield: hit["recipe"]["yield"].to_i}

        recipe = Recipe.new(api_hash)
        recipe_list.push(recipe)
      end
      return recipe_list
    else
      return []
    end
  end
end
