assets = {}

assets.color_bg = Color("#070203")
assets.color_jumperscore = Color("#ecb72f")
assets.color_jumperlose = Color("#d60042")
assets.color_jumperbonus = Color("#00b9f7")

assets.color_walls =  Color("#bcb3aa")
assets.color_disker = Color("#d60000")
assets.color_effects = Color("#bcb3aa")

assets.main_font = love.graphics.newFont('assets/fonts/FutilePro.ttf', 16)
assets.secondary_font = love.graphics.newFont('assets/fonts/m5x7.ttf', 16)

assets.main_font:setFilter('nearest', 'nearest')
assets.secondary_font:setFilter('nearest', 'nearest')

sfx = {}

sfx_volume = 1

sfx.slice = Sound('slice.ogg', {volume = .7 * sfx_volume})
sfx.combo = Sound('combo.ogg', {volume = 1 * sfx_volume})
sfx.ost = Sound('ost.ogg', { volume = .9 * sfx_volume, loop = true})
sfx.hit = Sound('hit.ogg', { volume = .8 * sfx_volume})
sfx.fall = Sound('fall.ogg', { volume = .7 * sfx_volume})
sfx.death = Sound('death.ogg', { volume = .65 * sfx_volume})
sfx.death2 = Sound('death2.ogg', { volume = .8 * sfx_volume})
sfx.scum = Sound('scum.ogg', { volume = .5 * sfx_volume})
sfx.fail = Sound('fail.wav', { volume = .5 * sfx_volume})
sfx.powerup = Sound('powerup.wav', { volume = .8 * sfx_volume})
sfx.powerup2 = Sound('powerup2.wav', { volume = .8 * sfx_volume})
sfx.ohgod = Sound('ohgod.ogg', { volume = .3 * sfx_volume})
sfx.triple = Sound('triple.ogg', { volume = .2 * sfx_volume})
sfx.horns = Sound('horns.mp3', { volume = .6 * sfx_volume})

if not web then
   for s, _ in pairs(sfx) do
      sfx[s].default_v = sfx[s].volume
   end
end

function update_volume(v)
   for s, _ in pairs(sfx) do
      sfx[s].volume = sfx[s].default_v * sfx_volume
   end
   love.audio.setVolume(sfx.ost.volume * sfx_volume)
   sfx.fail:play()
end
