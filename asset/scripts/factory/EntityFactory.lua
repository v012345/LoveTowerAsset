EntityFactory = EntityFactory or {}

function EntityFactory:load()
end

---@param entityType IEntity
---@param ... any
---@return IEntity
function EntityFactory:create(entityType, ...)
    return entityType.new(...)
end

return EntityFactory
