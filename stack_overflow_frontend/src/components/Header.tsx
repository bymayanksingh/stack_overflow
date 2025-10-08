import React from 'react';
import { Link } from 'react-router-dom';

const Header: React.FC = () => {
  return (
    <header className="bg-white border-b border-so-border shadow-sm">
      <div className="container mx-auto px-4">
        <div className="flex items-center justify-between h-16">
          {/* Logo */}
          <Link to="/" className="flex items-center space-x-2">
            <div className="w-8 h-8 bg-so-orange rounded flex items-center justify-center">
              <span className="text-white font-bold text-sm">S</span>
            </div>
            <span className="text-xl font-bold text-so-blue">StackOverflow</span>
          </Link>

          {/* Navigation */}
          <nav className="flex items-center space-x-4">
            <Link
              to="/"
              className="text-so-gray hover:text-so-blue px-3 py-2 rounded-md text-sm font-medium"
            >
              Questions
            </Link>
            <Link
              to="/user"
              className="text-so-gray hover:text-so-blue px-3 py-2 rounded-md text-sm font-medium"
            >
              Users
            </Link>
          </nav>
        </div>
      </div>
    </header>
  );
};

export default Header;
