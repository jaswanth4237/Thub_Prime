/**
 * Role-Based Access Control Middleware
 * Checks if the user has the required role to access the resource.
 */
const authorize = (allowedRoles) => {
    return (req, res, next) => {
        // In a production app, the role would come from a verified JWT token.
        // For this implementation, we look at the 'x-user-role' header.
        const userRole = req.headers['x-user-role'] || 'trainee';

        if (!allowedRoles.includes(userRole)) {
            console.warn(`=== Unauthorized access attempt: Role '${userRole}' tried to access a restricted resource.`);
            return res.status(403).json({
                success: false,
                message: "Access Denied: You do not have the required permissions.",
                requiredRoles: allowedRoles
            });
        }

        next();
    };
};

module.exports = { authorize };
